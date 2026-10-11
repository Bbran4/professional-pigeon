extends Node2D
class_name PigeonSpawner

signal ate_food(points: int)
signal visitor_count_changed(count: int)

@export var pigeon_scene: PackedScene
@export var feeder: SeedFeeder
@export var arrival_interval: float = 0.25
@export var park_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)
@export var landing_spots: Array[Vector2] = [
	Vector2(185.0, 112.0), Vector2(780.0, 170.0), Vector2(300.0, 240.0),
	Vector2(450.0, 260.0), Vector2(620.0, 460.0), Vector2(850.0, 430.0),
	Vector2(1010.0, 250.0),
]

const BRAIN_SCRIPT := preload("res://scripts/game/park_pigeon_brain.gd")
const FEATHER_SCENE := preload("res://scenes/park/feather.tscn")
const BENCH_SCENE := preload("res://scenes/park/bench.tscn")
const SEED_FEEDER_SCENE := preload("res://scenes/park/seed_feeder.tscn")
const BENCH_FEEDER_SCRIPT := preload("res://scripts/game/bench_feeder.gd")

var day_active := false
var visitors: Array[Dictionary] = []
var reserved_perches: Dictionary = {}
var _pending_points_by_pigeon: Dictionary = {}
var _spawn_delay_pending := false
var _retry := 0.0
var _spawned_benches: Dictionary = {}
var _spawned_bench_feeders: Dictionary = {}
var _spawned_nests: Array[Marker2D] = []
var _fountain_instance: Node2D


func _ready() -> void:
	set_process(true)
	if feeder == null:
		feeder = get_parent().get_node_or_null("StarterFeeder") as SeedFeeder
	if not ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_spawn_park_upgrades.call_deferred()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	_spawn_park_upgrades.call_deferred()


func _process(delta: float) -> void:
	if not day_active:
		_retry = 0.0
		return
	_retry += delta
	if _retry >= 0.5:
		_retry = 0.0
		if not _spawn_delay_pending:
			_spawn_available_visitors()


func _spawn_park_upgrades() -> void:
	var park := get_parent()
	if not is_instance_valid(park):
		return

	# These are additional benches; the original bench and feeder are authored in game.tscn.
	# Keep spawned instances keyed by index so buying a later upgrade adds only the new items.
	var bench_positions: Array[Vector2] = [
		Vector2(300, 500),
		Vector2(600, 500),
		Vector2(990, 230),
	]
	var requested_benches := clampi(int(ProgressionManager.get_effect_value(EffectIds.BENCH_COUNT_ADD)), 0, bench_positions.size())
	for index in range(requested_benches):
		if not _spawned_benches.has(index) or not is_instance_valid(_spawned_benches[index]):
			var bench := BENCH_SCENE.instantiate() as Node2D
			if bench == null:
				push_error("PigeonSpawner: failed to instantiate scenes/park/bench.tscn.")
				continue
			bench.name = "UnlockedBench_%d" % (index + 1)
			park.add_child(bench)
			bench.position = bench_positions[index]
			_spawned_benches[index] = bench

		if not _spawned_bench_feeders.has(index) or not is_instance_valid(_spawned_bench_feeders[index]):
			var bench_feeder := _create_bench_feeder(index)
			if bench_feeder == null:
				continue
			bench_feeder.name = "UnlockedBenchFeeder_%d" % (index + 1)
			park.add_child(bench_feeder)
			bench_feeder.position = bench_positions[index]
			_spawned_bench_feeders[index] = bench_feeder

	# If an upgrade is reset, remove its park objects too.
	for key in _spawned_benches.keys():
		if int(key) >= requested_benches:
			var old_bench := _spawned_benches[key] as Node
			if is_instance_valid(old_bench):
				old_bench.queue_free()
			_spawned_benches.erase(key)
	for key in _spawned_bench_feeders.keys():
		if int(key) >= requested_benches:
			var old_feeder := _spawned_bench_feeders[key] as Node
			if is_instance_valid(old_feeder):
				old_feeder.queue_free()
			_spawned_bench_feeders.erase(key)

	if ProgressionManager.get_effect_value(EffectIds.FOUNTAIN_UNLOCK) > 0.0:
		if not is_instance_valid(_fountain_instance):
			_spawn_fountain(park)
	elif is_instance_valid(_fountain_instance):
		_fountain_instance.queue_free()
		_fountain_instance = null

	var wants_nests := ProgressionManager.get_effect_value(EffectIds.TREE_NESTS) > 0.0
	if wants_nests and _spawned_nests.is_empty():
		var nest_positions: Array[Vector2] = [Vector2(140, 155), Vector2(210, 140), Vector2(245, 190)]
		for nest_position in nest_positions:
			var nest := Marker2D.new()
			nest.name = "UnlockedTreeNest"
			nest.add_to_group("perch_spots")
			park.add_child(nest)
			nest.global_position = nest_position
			_spawned_nests.append(nest)
	elif not wants_nests and not _spawned_nests.is_empty():
		for nest in _spawned_nests:
			if is_instance_valid(nest):
				nest.queue_free()
		_spawned_nests.clear()


func _create_bench_feeder(index: int) -> Node2D:
	var bench_feeder := Node2D.new()
	bench_feeder.set_script(BENCH_FEEDER_SCRIPT)
	var seed_feeder := SEED_FEEDER_SCENE.instantiate() as Node2D
	if seed_feeder == null:
		push_error("PigeonSpawner: failed to instantiate scenes/park/seed_feeder.tscn for bench %d." % (index + 1))
		bench_feeder.free()
		return null
	seed_feeder.name = "SeedFeeder"
	seed_feeder.position = Vector2(0, 78)
	bench_feeder.add_child(seed_feeder)
	for spawn_index in range(3):
		var perch := Marker2D.new()
		perch.name = "BenchSpawn%d" % (spawn_index + 1)
		perch.add_to_group("perch_spots")
		perch.position = Vector2(-48 + spawn_index * 48, 12)
		bench_feeder.add_child(perch)
	return bench_feeder


func _spawn_fountain(park: Node) -> void:
	if is_instance_valid(_fountain_instance):
		return
	var fountain := Node2D.new()
	fountain.name = "UnlockedFountain"
	var base := Polygon2D.new()
	base.polygon = PackedVector2Array([-70, -16, -55, -38, 0, -46, 55, -38, 70, -16, 58, 12, 0, 24, -58, 12])
	base.color = Color(0.54, 0.52, 0.46, 1.0)
	fountain.add_child(base)
	var water := Polygon2D.new()
	water.position = Vector2(0, -15)
	water.polygon = PackedVector2Array([-48, -9, -35, -23, 0, -28, 35, -23, 48, -9, 35, 4, 0, 8, -35, 4])
	water.color = Color(0.31, 0.65, 0.72, 1.0)
	fountain.add_child(water)
	var pillar := Polygon2D.new()
	pillar.position = Vector2(0, -34)
	pillar.polygon = PackedVector2Array([-8, -14, 8, -14, 11, 7, -11, 7])
	pillar.color = Color(0.65, 0.62, 0.54, 1.0)
	fountain.add_child(pillar)
	var fountain_perches: Array[Vector2] = [Vector2(-82, 5), Vector2(82, 5), Vector2(0, -65), Vector2(0, 42)]
	for perch_position in fountain_perches:
		var perch := Marker2D.new()
		perch.add_to_group("perch_spots")
		perch.position = perch_position
		fountain.add_child(perch)
	var fountain_marker := park.get_node_or_null("FountainMarker") as Node2D
	park.add_child(fountain)
	if fountain_marker != null:
		fountain.global_position = fountain_marker.global_position
	_fountain_instance = fountain


func start_day() -> void:
	if day_active:
		return
	day_active = true
	_spawn_available_visitors()


func end_day() -> void:
	# A day ending stops arrivals and removes any visitors still in flight.
	day_active = false
	_spawn_delay_pending = false
	for visitor in visitors:
		var pigeon := visitor.get("pigeon") as Pigeon
		if is_instance_valid(pigeon):
			pigeon.queue_free()
	visitors.clear()
	reserved_perches.clear()
	_pending_points_by_pigeon.clear()
	visitor_count_changed.emit(0)


func get_active_count() -> int:
	_prune_invalid_visitors()
	return visitors.size()


func _get_max_pigeons() -> int:
	return maxi(1, 1 + int(ProgressionManager.get_effect_value(EffectIds.MAX_PIGEONS)) + int(ProgressionManager.get_effect_value(EffectIds.TREE_NESTS)))


func _spawn_available_visitors() -> void:
	if not day_active or pigeon_scene == null or _spawn_delay_pending:
		return
	_prune_invalid_visitors()
	# Never invite more pigeons than the park has seeds available to feed them.
	# This prevents a whole flock from competing for a single remaining seed.
	var available_seeds := _get_available_seed_count()
	while day_active and visitors.size() < _get_max_pigeons() and visitors.size() < available_seeds:
		var perch := _reserve_perch()
		if perch.is_empty():
			return
		var food_source := _find_available_feeder()
		if food_source == null:
			_release_perch(str(perch.get("key", "")))
			return
		if not _spawn_visitor(perch, food_source):
			_release_perch(str(perch.get("key", "")))
			return
		if visitors.size() < _get_max_pigeons():
			_spawn_next_after_delay()
			return


func _get_available_seed_count() -> int:
	var total := 0
	for node in get_tree().get_nodes_in_group("feeders"):
		var candidate := node as SeedFeeder
		if candidate != null and candidate.is_visible_in_tree():
			total += candidate.seeds_remaining
	if total == 0 and is_instance_valid(feeder) and feeder.is_visible_in_tree():
		total = feeder.seeds_remaining
	return total


func _spawn_visitor(perch: Dictionary, food_source: SeedFeeder) -> bool:
	var pigeon := pigeon_scene.instantiate() as Pigeon
	if pigeon == null:
		push_error("PigeonSpawner: pigeon_scene root must be a Pigeon.")
		return false
	get_parent().add_child(pigeon)
	pigeon.z_index = 20
	pigeon.z_as_relative = false
	var brain_node := Node.new()
	brain_node.set_script(BRAIN_SCRIPT)
	pigeon.add_child(brain_node)
	var brain := brain_node as ParkPigeonBrain
	if brain == null:
		push_error("PigeonSpawner: failed to attach ParkPigeonBrain.")
		pigeon.queue_free()
		return false

	brain.patience_timeout = maxf(1.0, brain.patience_timeout + ProgressionManager.get_effect_value(EffectIds.PIGEON_PATIENCE_ADD))
	if randf() < ProgressionManager.get_effect_value(EffectIds.RARE_VISITOR_CHANCE):
		brain.food_points += 2
	var perch_position: Vector2 = perch.position
	var from_left := randf() < 0.5
	var arrival := Vector2(park_bounds.position.x - 35.0, perch_position.y - 80.0) if from_left else Vector2(park_bounds.end.x + 35.0, perch_position.y - 80.0)
	var exit := Vector2(park_bounds.end.x + 55.0, perch_position.y - 80.0) if from_left else Vector2(park_bounds.position.x - 55.0, perch_position.y - 80.0)
	var perch_key := str(perch.key)

	brain.ate_food.connect(_on_ate_food.bind(pigeon))
	brain.feather_dropped.connect(_on_feather_dropped.bind(pigeon))
	brain.departed.connect(_on_visitor_departed.bind(pigeon, perch_key))
	visitors.append({"pigeon": pigeon, "brain": brain, "perch_key": perch_key})
	brain.start_day(perch_position, arrival, exit)
	brain.set_food(food_source)
	visitor_count_changed.emit(visitors.size())
	return true


func _reserve_perch() -> Dictionary:
	var candidates: Array[Dictionary] = []
	for marker in get_tree().get_nodes_in_group("perch_spots"):
		if not is_instance_valid(marker) or not marker is Node2D or not marker.is_visible_in_tree():
			continue
		var key := str(marker.get_instance_id())
		if not reserved_perches.has(key):
			candidates.append({"key": key, "position": (marker as Node2D).global_position})
	if not candidates.is_empty():
		var selected: Dictionary = candidates[randi_range(0, candidates.size() - 1)]
		reserved_perches[str(selected.key)] = true
		return selected
	var landing_candidates: Array[Dictionary] = []
	for index in range(landing_spots.size()):
		var key := "landing_%d" % index
		if reserved_perches.has(key):
			continue
		landing_candidates.append({"key": key, "position": landing_spots[index]})
	if landing_candidates.is_empty():
		return {}
	var selected: Dictionary = landing_candidates[randi_range(0, landing_candidates.size() - 1)]
	reserved_perches[str(selected.key)] = true
	return selected


func _release_perch(key: String) -> void:
	reserved_perches.erase(key)


func _find_available_feeder() -> SeedFeeder:
	var available: Array[SeedFeeder] = []
	for node in get_tree().get_nodes_in_group("feeders"):
		var candidate := node as SeedFeeder
		if candidate == null or not candidate.is_visible_in_tree() or not candidate.can_feed():
			continue
		available.append(candidate)
	if available.is_empty():
		if is_instance_valid(feeder) and feeder.is_visible_in_tree() and feeder.can_feed():
			return feeder
		return null
	return available[randi_range(0, available.size() - 1)]


func _on_ate_food(points: int, pigeon: Pigeon) -> void:
	_pending_points_by_pigeon[pigeon.get_instance_id()] = points


func _on_feather_dropped(drop_position: Vector2, pigeon: Pigeon) -> void:
	var point_reward := int(_pending_points_by_pigeon.get(pigeon.get_instance_id(), 0))
	_pending_points_by_pigeon.erase(pigeon.get_instance_id())
	_spawn_feather(drop_position, point_reward)
	for index in range(int(ProgressionManager.get_effect_value(EffectIds.FEATHER_COUNT_ADD))):
		var offset := Vector2(randf_range(-24.0, 24.0), randf_range(-12.0, 12.0))
		# Every feather is an individual collectible and should grant the visit's reward.
		_spawn_feather(drop_position + offset, point_reward)


func _spawn_feather(spawn_position: Vector2, point_reward: int = 0) -> void:
	var feather := FEATHER_SCENE.instantiate() as Feather
	if feather == null:
		push_error("PigeonSpawner: feather scene root must be a Feather.")
		return
	get_parent().add_child(feather)
	feather.global_position = spawn_position
	feather.z_index = 20
	feather.z_as_relative = false
	feather.point_value = point_reward
	feather.point_value += int(ProgressionManager.get_effect_value(EffectIds.FEATHER_VALUE_ADD))
	if randf() < ProgressionManager.get_effect_value(EffectIds.GOLDEN_FEATHER_CHANCE):
		feather.point_value += 3

func _on_visitor_departed(pigeon: Pigeon, perch_key: String) -> void:
	for index in range(visitors.size() - 1, -1, -1):
		var visitor: Dictionary = visitors[index]
		if visitor.get("pigeon") == pigeon:
			visitors.remove_at(index)
			break
	_release_perch(perch_key)
	if is_instance_valid(pigeon):
		pigeon.queue_free()
	visitor_count_changed.emit(visitors.size())
	if day_active:
		_spawn_next_after_delay()


func _spawn_next_after_delay() -> void:
	if _spawn_delay_pending:
		return
	_spawn_delay_pending = true
	var delay := maxf(0.1, arrival_interval - ProgressionManager.get_effect_value(EffectIds.ARRIVAL_SPEED_REDUCTION) - ProgressionManager.get_effect_value(EffectIds.FOUNTAIN_UNLOCK) * 0.2)
	if randf() < ProgressionManager.get_effect_value(EffectIds.PAIR_ARRIVALS):
		delay = 0.0
	get_tree().create_timer(delay).timeout.connect(_on_spawn_delay_timeout, CONNECT_ONE_SHOT)


func _on_spawn_delay_timeout() -> void:
	if not is_inside_tree():
		return
	_spawn_delay_pending = false
	if day_active:
		_spawn_available_visitors()


func _prune_invalid_visitors() -> void:
	for index in range(visitors.size() - 1, -1, -1):
		var visitor: Dictionary = visitors[index]
		var pigeon := visitor.get("pigeon") as Pigeon
		if is_instance_valid(pigeon):
			continue
		_release_perch(str(visitor.get("perch_key", "")))
		visitors.remove_at(index)
