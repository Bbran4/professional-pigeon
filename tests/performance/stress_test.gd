extends Node

## Run with:
## godot --path . res://tests/performance/stress_test.tscn
## Metrics are printed once per second in CSV format for easy comparison.

const GAME_SCENE: PackedScene = preload("res://scenes/game.tscn")
const FEEDER_SCENE: PackedScene = preload("res://scenes/park/seed_feeder.tscn")
const FEATHER_SCENE: PackedScene = preload("res://scenes/park/feather.tscn")
const PIGEON_SCENE: PackedScene = preload("res://scenes/park/npc_pigeon.tscn")

@export_range(1, 600, 1) var duration_seconds: int = 60
@export_range(1, 500, 1) var stress_visitors: int = 100
@export_range(1, 500, 1) var stress_feeders: int = 100
@export_range(1, 2000, 1) var stress_collectibles: int = 500

var _elapsed := 0.0
var _next_sample := 0.0
var _game: Node2D
var _frame_samples_ms: Array[float] = []
var _memory_samples_mb: Array[float] = []


func _ready() -> void:
	print("STRESS_TEST_BEGIN,visitors=%d,feeders=%d,collectibles=%d,duration_seconds=%d" % [
		stress_visitors, stress_feeders, stress_collectibles, duration_seconds
	])
	print("elapsed_s,process_ms,physics_ms,static_memory_mb,object_count,node_count,active_2d_objects,visitor_count,feeder_count,collectible_count")
	_game = GAME_SCENE.instantiate() as Node2D
	if _game == null:
		push_error("Stress test: game scene root must be Node2D.")
		get_tree().quit(1)
		return
	add_child(_game)
	await get_tree().process_frame
	_spawn_stress_load()
	await get_tree().process_frame
	_sample_metrics()


func _process(delta: float) -> void:
	if _game == null:
		return
	_elapsed += delta
	if _elapsed >= _next_sample:
		_next_sample = _elapsed + 1.0
		_sample_metrics()
	if _elapsed >= float(duration_seconds):
		_print_summary()
		get_tree().quit()


func _spawn_stress_load() -> void:
	var feeder_nodes: Array[SeedFeeder] = []
	for index in range(stress_feeders):
		var feeder_node := FEEDER_SCENE.instantiate() as SeedFeeder
		if feeder_node == null:
			push_error("Stress test: seed feeder scene root must be SeedFeeder.")
			continue
		_game.add_child(feeder_node)
		feeder_node.position = Vector2(60.0 + float(index % 20) * 45.0, 80.0 + float(index / 20) * 45.0)
		feeder_nodes.append(feeder_node)

	for index in range(stress_collectibles):
		var feather := FEATHER_SCENE.instantiate() as Collectible
		if feather == null:
			push_error("Stress test: feather scene root must extend Collectible.")
			return
		_game.add_child(feather)
		feather.position = Vector2(40.0 + float(index % 50) * 20.0, 100.0 + float(index / 50) * 18.0)
		feather.point_value = 1

	for index in range(stress_visitors):
		var pigeon := PIGEON_SCENE.instantiate() as Pigeon
		if pigeon == null:
			push_error("Stress test: pigeon scene root must be Pigeon.")
			return
		_game.add_child(pigeon)
		pigeon.position = Vector2(80.0 + float(index % 20) * 40.0, 140.0 + float(index / 20) * 35.0)
		var brain := pigeon.get_node_or_null("ParkPigeonBrain") as ParkPigeonBrain
		if brain == null:
			push_error("Stress test: pigeon scene is missing ParkPigeonBrain.")
			pigeon.queue_free()
			continue
		var perch := pigeon.position
		var arrival := perch + Vector2(-100.0, -40.0)
		var exit := perch + Vector2(100.0, -40.0)
		brain.start_day(perch, arrival, exit)
		if not feeder_nodes.is_empty():
			brain.set_food(feeder_nodes[index % feeder_nodes.size()])


func _sample_metrics() -> void:
	var process_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_ms := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var memory_mb := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / (1024.0 * 1024.0)
	_frame_samples_ms.append(process_ms)
	_memory_samples_mb.append(memory_mb)
	print("%.2f,%.3f,%.3f,%.2f,%d,%d,%d,%d,%d,%d" % [
		_elapsed,
		process_ms,
		physics_ms,
		memory_mb,
		int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		int(Performance.get_monitor(Performance.NODE_COUNT)),
		int(Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)),
		_game.get_tree().get_nodes_in_group("pigeons").size(),
		_game.get_tree().get_nodes_in_group("feeders").size(),
		_game.get_tree().get_nodes_in_group("collectibles").size()
	])


func _print_summary() -> void:
	var peak_process_ms := 0.0
	var peak_memory_mb := 0.0
	for value in _frame_samples_ms:
		peak_process_ms = maxf(peak_process_ms, value)
	for value in _memory_samples_mb:
		peak_memory_mb = maxf(peak_memory_mb, value)
	print("STRESS_TEST_SUMMARY,samples=%d,peak_process_ms=%.3f,peak_static_memory_mb=%.2f" % [
		_frame_samples_ms.size(), peak_process_ms, peak_memory_mb
	])
