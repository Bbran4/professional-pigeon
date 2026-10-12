extends Node

## Run with:
## godot --path . res://tests/performance/stress_test.tscn
## Choose a scenario in the Inspector before running.
## Prints one-second CSV samples and steady-state timing summaries.

const GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")
const FEEDER_SCENE: PackedScene = preload("res://scenes/park/seed_feeder.tscn")
const FEATHER_SCENE: PackedScene = preload("res://scenes/park/feather.tscn")
const PIGEON_SCENE: PackedScene = preload("res://scenes/park/npc_pigeon.tscn")

enum Scenario {
	BASELINE,
	STATIC_STRESS,
	ACTIVE_STRESS,
}

@export var scenario: Scenario = Scenario.ACTIVE_STRESS
@export_range(1, 600, 1) var duration_seconds: int = 60
@export_range(1, 500, 1) var stress_visitors: int = 100
@export_range(1, 500, 1) var stress_feeders: int = 100
@export_range(1, 2000, 1) var stress_collectibles: int = 500
@export_range(1, 30, 1) var warmup_seconds: int = 5
@export_range(0.05, 2.0, 0.05) var feeder_refill_interval: float = 0.25

var _elapsed := 0.0
var _next_sample := 0.0
var _refill_elapsed := 0.0
var _game: Node2D
var _stress_feeders: Array[SeedFeeder] = []
var _stress_pigeons: Array[Pigeon] = []
var _frame_samples_ms: Array[float] = []
var _process_samples_ms: Array[float] = []
var _physics_samples_ms: Array[float] = []
var _memory_samples_mb: Array[float] = []


func _ready() -> void:
	print("STRESS_TEST_BEGIN,scenario=%s,visitors=%d,feeders=%d,collectibles=%d,duration_seconds=%d,warmup_seconds=%d" % [
		Scenario.keys()[scenario].to_lower(),
		stress_visitors,
		stress_feeders,
		stress_collectibles,
		duration_seconds,
		warmup_seconds,
	])
	print("elapsed_s,frame_delta_ms,process_ms,physics_ms,static_memory_mb,object_count,node_count,active_2d_objects,visitor_count,active_visitor_count,feeder_count,collectible_count")

	_game = GAME_SCENE.instantiate() as Node2D
	if _game == null:
		push_error("Stress test: game scene root must be Node2D.")
		get_tree().quit(1)
		return
	add_child(_game)
	await get_tree().process_frame

	if scenario != Scenario.BASELINE:
		_spawn_stress_objects()
	if scenario == Scenario.ACTIVE_STRESS:
		_spawn_stress_visitors()

	await get_tree().process_frame
	_sample_metrics()


func _process(delta: float) -> void:
	if _game == null:
		return

	_elapsed += delta
	if scenario == Scenario.ACTIVE_STRESS:
		_keep_active_stress_running(delta)

	var frame_delta_ms := delta * 1000.0
	if _elapsed >= float(warmup_seconds):
		_frame_samples_ms.append(frame_delta_ms)

	if _elapsed >= _next_sample:
		_next_sample = _elapsed + 1.0
		_sample_metrics(frame_delta_ms)

	if _elapsed >= float(duration_seconds):
		_print_summary()
		get_tree().quit()


func _spawn_stress_objects() -> void:
	for index in range(stress_feeders):
		var feeder_node := FEEDER_SCENE.instantiate() as SeedFeeder
		if feeder_node == null:
			push_error("Stress test: seed feeder scene root must be SeedFeeder.")
			continue
		_game.add_child(feeder_node)
		feeder_node.position = Vector2(
			60.0 + float(index % 20) * 45.0,
			80.0 + float(index / 20) * 45.0
		)
		_stress_feeders.append(feeder_node)

	for index in range(stress_collectibles):
		var feather := FEATHER_SCENE.instantiate() as Collectible
		if feather == null:
			push_error("Stress test: feather scene root must extend Collectible.")
			return
		_game.add_child(feather)
		feather.position = Vector2(
			40.0 + float(index % 50) * 20.0,
			100.0 + float(index / 50) * 18.0
		)
		feather.point_value = 1


func _spawn_stress_visitors() -> void:
	for index in range(stress_visitors):
		var pigeon := PIGEON_SCENE.instantiate() as Pigeon
		if pigeon == null:
			push_error("Stress test: pigeon scene root must be Pigeon.")
			return
		_game.add_child(pigeon)
		pigeon.add_to_group("stress_test_visitors")
		pigeon.position = Vector2(
			80.0 + float(index % 20) * 40.0,
			140.0 + float(index / 20) * 35.0
		)
		var brain := pigeon.get_node_or_null("ParkPigeonBrain") as ParkPigeonBrain
		if brain == null:
			push_error("Stress test: pigeon scene is missing ParkPigeonBrain.")
			pigeon.queue_free()
			continue
		_stress_pigeons.append(pigeon)
		_restart_visitor(pigeon, index)


func _restart_visitor(pigeon: Pigeon, index: int) -> void:
	if not is_instance_valid(pigeon):
		return
	var brain := pigeon.get_node_or_null("ParkPigeonBrain") as ParkPigeonBrain
	if brain == null:
		return
	var perch := Vector2(
		80.0 + float(index % 20) * 40.0,
		140.0 + float(index / 20) * 35.0
	)
	var arrival := perch + Vector2(-100.0, -40.0)
	var exit := perch + Vector2(100.0, -40.0)
	brain.start_day(perch, arrival, exit)
	if not _stress_feeders.is_empty():
		brain.set_food(_stress_feeders[index % _stress_feeders.size()])


func _keep_active_stress_running(delta: float) -> void:
	_refill_elapsed += delta
	if _refill_elapsed >= feeder_refill_interval:
		_refill_elapsed = 0.0
		for feeder in _stress_feeders:
			if is_instance_valid(feeder):
				feeder.refill(feeder.get_seed_capacity())

	# Real visitor brains naturally depart after feeding or waiting. Restart
	# them so this scenario measures sustained behavior and movement, rather
	# than a large but mostly idle collection of visitor nodes.
	for index in range(_stress_pigeons.size()):
		var pigeon := _stress_pigeons[index]
		if not is_instance_valid(pigeon):
			continue
		var brain := pigeon.get_node_or_null("ParkPigeonBrain") as ParkPigeonBrain
		if brain != null and not brain.active:
			_restart_visitor(pigeon, index)


func _sample_metrics(frame_delta_ms: float = 0.0) -> void:
	var process_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_ms := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var memory_mb := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / (1024.0 * 1024.0)
	var visitor_count := _game.get_tree().get_nodes_in_group("stress_test_visitors").size()
	var active_visitor_count := _get_active_visitor_count()

	if _elapsed >= float(warmup_seconds):
		_process_samples_ms.append(process_ms)
		_physics_samples_ms.append(physics_ms)
		_memory_samples_mb.append(memory_mb)

	print("%.2f,%.3f,%.3f,%.3f,%.2f,%d,%d,%d,%d,%d,%d,%d" % [
		_elapsed,
		frame_delta_ms,
		process_ms,
		physics_ms,
		memory_mb,
		int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		int(Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)),
		visitor_count,
		active_visitor_count,
		_game.get_tree().get_nodes_in_group("feeders").size(),
		_game.get_tree().get_nodes_in_group("collectibles").size(),
	])


func _get_active_visitor_count() -> int:
	var active_count := 0
	for pigeon in _stress_pigeons:
		if not is_instance_valid(pigeon):
			continue
		var brain := pigeon.get_node_or_null("ParkPigeonBrain") as ParkPigeonBrain
		if brain != null and brain.active:
			active_count += 1
	return active_count


func _print_summary() -> void:
	print("STRESS_TEST_SUMMARY,scenario=%s,warmup_seconds=%d,frame_samples=%d,avg_frame_delta_ms=%.3f,median_frame_delta_ms=%.3f,p95_frame_delta_ms=%.3f,peak_frame_delta_ms=%.3f,avg_process_ms=%.3f,peak_process_ms=%.3f,avg_physics_ms=%.3f,peak_physics_ms=%.3f,peak_static_memory_mb=%.2f" % [
		Scenario.keys()[scenario].to_lower(),
		warmup_seconds,
		_frame_samples_ms.size(),
		_get_average(_frame_samples_ms),
		_get_percentile(_frame_samples_ms, 0.5),
		_get_percentile(_frame_samples_ms, 0.95),
		_get_peak(_frame_samples_ms),
		_get_average(_process_samples_ms),
		_get_peak(_process_samples_ms),
		_get_average(_physics_samples_ms),
		_get_peak(_physics_samples_ms),
		_get_peak(_memory_samples_mb),
	])


func _get_average(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for value in values:
		total += value
	return total / float(values.size())


func _get_peak(values: Array[float]) -> float:
	var peak := 0.0
	for value in values:
		peak = maxf(peak, value)
	return peak


func _get_percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var sorted_values := values.duplicate()
	sorted_values.sort()
	var index := clampi(
		int(ceil(percentile * float(sorted_values.size()))) - 1,
		0,
		sorted_values.size() - 1
	)
	return sorted_values[index]
