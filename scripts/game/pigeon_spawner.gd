extends Node2D
class_name PigeonSpawner

signal ate_food(points: int)
signal visitor_count_changed(count: int)

@export var pigeon_scene: PackedScene
@export var arrival_interval: float = 0.8
@export var park_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)
@export var landing_spots: Array[Vector2] = [
	Vector2(185.0, 112.0),
	Vector2(780.0, 170.0),
	Vector2(300.0, 240.0),
	Vector2(450.0, 260.0),
	Vector2(620.0, 460.0),
	Vector2(850.0, 430.0),
	Vector2(1010.0, 250.0),
]

const BRAIN_SCRIPT := preload("res://scripts/game/park_pigeon_brain.gd")

var day_active := false
var active_pigeon: Pigeon
var active_brain: ParkPigeonBrain
var active_food: Node2D
var pending_food: Array[Node2D] = []
var previous_spot_index := -1


func start_day() -> void:
	if day_active:
		return
	day_active = true
	_spawn_visitor()


func set_food(food: Node2D) -> void:
	if not day_active or food == null or not is_instance_valid(food):
		return
	pending_food.append(food)
	_assign_next_food()


func end_day() -> void:
	day_active = false
	pending_food.clear()
	active_food = null
	if is_instance_valid(active_brain):
		active_brain.end_day()
	if is_instance_valid(active_pigeon):
		active_pigeon.queue_free()
	active_pigeon = null
	active_brain = null
	visitor_count_changed.emit(0)


func get_active_count() -> int:
	return 1 if is_instance_valid(active_pigeon) else 0


func _spawn_visitor() -> void:
	if not day_active or is_instance_valid(active_pigeon) or pigeon_scene == null:
		return

	var pigeon := pigeon_scene.instantiate() as Pigeon
	if pigeon == null:
		push_error("PigeonSpawner: pigeon_scene root must be a Pigeon.")
		return

	add_child(pigeon)
	active_pigeon = pigeon

	var brain_node := Node.new()
	brain_node.set_script(BRAIN_SCRIPT)
	pigeon.add_child(brain_node)
	active_brain = brain_node as ParkPigeonBrain
	if active_brain == null:
		push_error("PigeonSpawner: failed to attach ParkPigeonBrain.")
		pigeon.queue_free()
		active_pigeon = null
		return

	active_brain.ate_food.connect(_on_ate_food)
	active_brain.departed.connect(_on_visitor_departed)

	var spot_index := _choose_spot_index()
	var perch := landing_spots[spot_index]
	var from_left := randf() < 0.5
	var arrival := Vector2(park_bounds.position.x - 35.0, perch.y - 80.0) if from_left else Vector2(park_bounds.end.x + 35.0, perch.y - 80.0)
	var exit := Vector2(park_bounds.end.x + 55.0, perch.y - 80.0) if from_left else Vector2(park_bounds.position.x - 55.0, perch.y - 80.0)

	active_brain.call_deferred("start_day", perch, arrival, exit)
	visitor_count_changed.emit(1)
	_assign_next_food()


func _choose_spot_index() -> int:
	if landing_spots.is_empty():
		return 0
	if landing_spots.size() == 1:
		previous_spot_index = 0
		return 0

	var index := randi_range(0, landing_spots.size() - 1)
	if index == previous_spot_index:
		index = (index + randi_range(1, landing_spots.size() - 1)) % landing_spots.size()
	previous_spot_index = index
	return index


func _assign_next_food() -> void:
	if not day_active or not is_instance_valid(active_brain) or is_instance_valid(active_food):
		return

	while not pending_food.is_empty():
		var food := pending_food.pop_front()
		if not is_instance_valid(food) or not food.visible:
			continue

		active_food = food
		active_brain.set_food(food)
		return


func _on_ate_food(points: int) -> void:
	active_food = null
	ate_food.emit(points)


func _on_visitor_departed() -> void:
	if is_instance_valid(active_pigeon):
		active_pigeon.queue_free()
	active_pigeon = null
	active_brain = null
	active_food = null
	visitor_count_changed.emit(0)
	if day_active:
		_spawn_next_after_delay()


func _spawn_next_after_delay() -> void:
	await get_tree().create_timer(arrival_interval).timeout
	if day_active and not is_instance_valid(active_pigeon):
		_spawn_visitor()
