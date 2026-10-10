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

var day_active := false
var visitors: Array[Dictionary] = []
var reserved_perches: Dictionary = {}
var _spawn_delay_pending := false


func _ready() -> void:
	if feeder == null:
		feeder = get_parent().get_node_or_null("StarterFeeder") as SeedFeeder


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
	return maxi(1, 1 + int(ProgressionManager.get_effect_value(&"max_pigeons")))


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
		_spawn_available_visitors()


func _spawn_next_after_delay() -> void:
	if _spawn_delay_pending:
		return
	_spawn_delay_pending = true
	await get_tree().create_timer(maxf(0.1, arrival_interval - ProgressionManager.get_effect_value(&"arrival_speed_reduction"))).timeout
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
