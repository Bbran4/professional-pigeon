extends Node2D
class_name PigeonSpawner

signal ate_food(points: int)
signal visitor_count_changed(count: int)

@export var pigeon_scene: PackedScene
@export var feeder: SeedFeeder
@export var arrival_interval: float = 0.8
@export var park_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)
@export var landing_spots: Array[Vector2] = [
	Vector2(185.0, 112.0), Vector2(780.0, 170.0), Vector2(300.0, 240.0),
	Vector2(450.0, 260.0), Vector2(620.0, 460.0), Vector2(850.0, 430.0),
	Vector2(1010.0, 250.0),
]

const BRAIN_SCRIPT := preload("res://scripts/game/park_pigeon_brain.gd")
const FEATHER_SCENE := preload("res://scenes/park/feather.tscn")
const BENCH_SCENE := preload("res://scenes/park/bench.tscn")
const BENCH_FEEDER_SCENE := preload("res://scenes/park/bench_feeder.tscn")

var day_active := false
var visitors: Array[Dictionary] = []
var reserved_perches: Dictionary = {}
var _spawn_delay_pending := false


func _ready() -> void:
	if feeder == null:
		feeder = get_parent().get_node_or_null("StarterFeeder") as SeedFeeder
	_spawn_park_upgrades.call_deferred()


func _spawn_park_upgrades() -> void:
	var park := get_parent()
	var bench_positions: Array[Vector2] = [Vector2(300, 500), Vector2(600, 500), Vector2(820, 300)]
	var bench_count := mini(int(ProgressionManager.get_effect_value(&"bench_count_add")), bench_positions.size())
	for index in range(bench_count):
		var bench := BENCH_SCENE.instantiate() as Node2D
		var bench_feeder := BENCH_FEEDER_SCENE.instantiate() as Node2D
		if bench != null and bench_feeder != null:
			park.add_child(bench)
			park.add_child(bench_feeder)
			bench.position = bench_positions[index]
			bench_feeder.position = bench_positions[index]
	if ProgressionManager.get_effect_value(&"fountain_unlock") > 0.0:
		_spawn_fountain(park)
	if ProgressionManager.get_effect_value(&"tree_nests") > 0.0:
		var nest_positions: Array[Vector2] = [Vector2(140, 155), Vector2(210, 140), Vector2(245, 190)]
		for nest_position in nest_positions:
			var nest := Marker2D.new()
			nest.add_to_group("perch_spots")
			park.add_child(nest)
			nest.global_position = nest_position


func _spawn_fountain(park: Node) -> void:
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


func start_day() -> void:
	if day_active:
		return
	day_active = true
	_spawn_available_visitors()


func end_day() -> void:
	# Stop new arrivals while allowing active visitors to finish or time out.
	day_active = false
	if visitors.is_empty():
		visitor_count_changed.emit(0)


func get_active_count() -> int:
	_prune_invalid_visitors()
	return visitors.size()


func _get_max_pigeons() -> int:
	return maxi(1, 1 + int(ProgressionManager.get_effect_value(&"max_pigeons")) + int(ProgressionManager.get_effect_value(&"tree_nests")))


func _spawn_available_visitors() -> void:
	if not day_active or pigeon_scene == null or _spawn_delay_pending:
		return
	_prune_invalid_visitors()
	while day_active and visitors.size() < _get_max_pigeons():
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


func _spawn_visitor(perch: Dictionary, food_source: SeedFeeder) -> bool:
	var pigeon := pigeon_scene.instantiate() as Pigeon
	if pigeon == null:
		push_error("PigeonSpawner: pigeon_scene root must be a Pigeon.")
		return false
	get_parent().add_child(pigeon)
	var brain_node := Node.new()
	brain_node.set_script(BRAIN_SCRIPT)
	pigeon.add_child(brain_node)
	var brain := brain_node as ParkPigeonBrain
	if brain == null:
		push_error("PigeonSpawner: failed to attach ParkPigeonBrain.")
		pigeon.queue_free()
		return false

	brain.patience_timeout = maxf(1.0, brain.patience_timeout + ProgressionManager.get_effect_value(&"pigeon_patience_add"))
	if randf() < ProgressionManager.get_effect_value(&"rare_visitor_chance"):
		brain.food_points += 2
	var perch_position: Vector2 = perch.position
	var from_left := randf() < 0.5
	var arrival := Vector2(park_bounds.position.x - 35.0, perch_position.y - 80.0) if from_left else Vector2(park_bounds.end.x + 35.0, perch_position.y - 80.0)
	var exit := Vector2(park_bounds.end.x + 55.0, perch_position.y - 80.0) if from_left else Vector2(park_bounds.position.x - 55.0, perch_position.y - 80.0)
	var perch_key := str(perch.key)

	brain.ate_food.connect(_on_ate_food)
	brain.feather_dropped.connect(_on_feather_dropped)
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
	for index in range(landing_spots.size()):
		var key := "landing_%d" % index
		if reserved_perches.has(key):
			continue
		var selected := {"key": key, "position": landing_spots[index]}
		reserved_perches[key] = true
		return selected
	return {}


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


func _on_ate_food(points: int) -> void:
	ate_food.emit(points)


func _on_feather_dropped(drop_position: Vector2) -> void:
	var feather := FEATHER_SCENE.instantiate() as Feather
	if feather == null:
		push_error("PigeonSpawner: feather scene root must be a Feather.")
		return
	get_parent().add_child(feather)
	feather.global_position = drop_position
	feather.coin_value += int(ProgressionManager.get_effect_value(&"feather_value_add"))
	if randf() < ProgressionManager.get_effect_value(&"golden_feather_chance"):
		feather.coin_value += 3
	for index in range(int(ProgressionManager.get_effect_value(&"feather_count_add"))):
		var extra := FEATHER_SCENE.instantiate() as Feather
		if extra == null:
			continue
		get_parent().add_child(extra)
		extra.global_position = drop_position + Vector2(randf_range(-24.0, 24.0), randf_range(-12.0, 12.0))
		extra.coin_value += int(ProgressionManager.get_effect_value(&"feather_value_add"))
		if randf() < ProgressionManager.get_effect_value(&"golden_feather_chance"):
			extra.coin_value += 3


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
	var delay := maxf(0.1, arrival_interval - ProgressionManager.get_effect_value(&"arrival_speed_reduction") - ProgressionManager.get_effect_value(&"fountain_unlock") * 0.2)
	if randf() < ProgressionManager.get_effect_value(&"pair_arrivals"):
		delay = 0.0
	await get_tree().create_timer(delay).timeout
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
