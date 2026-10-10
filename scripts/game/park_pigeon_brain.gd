extends Node
class_name ParkPigeonBrain

signal ate_food(points: int)
signal departed

@export var feather_scene: PackedScene = preload("res://scenes/park/feather.tscn")

enum VisitorState {
	ARRIVING,
	WAITING,
	FEEDING,
	DEPARTING,
}

@export var eating_duration: float = 2.0
@export var food_points: int = 1
@export var food_distance: float = 28.0
@export var arrival_distance: float = 18.0
@export var departure_distance: float = 40.0

var active := false
var visitor_state: VisitorState = VisitorState.ARRIVING
var target_food: Node2D
var pending_food: Array[Node2D] = []
var eating_timer := 0.0
var perch_position := Vector2.ZERO
var exit_position := Vector2.ZERO

@onready var pigeon: Pigeon = get_parent() as Pigeon
@onready var state_machine: StateMachine = $"../StateMachine"


func _ready() -> void:
	state_machine.set_process(false)
	state_machine.set_physics_process(false)


func start_day(perch: Vector2, arrival: Vector2, exit: Vector2) -> void:
	perch_position = perch
	exit_position = exit
	active = true
	visitor_state = VisitorState.ARRIVING
	target_food = null
	pending_food.clear()
	eating_timer = 0.0

	pigeon.show()
	pigeon.global_position = arrival
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO

	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	state_machine.transition(StateMachine.Intent.FLY)


func set_food(food: Node2D) -> void:
	if not active or visitor_state == VisitorState.DEPARTING:
		return
	if food == null or not is_instance_valid(food):
		return

	pending_food.append(food)
	_try_next_food()


func end_day() -> void:
	active = false
	target_food = null
	pending_food.clear()
	eating_timer = 0.0
	state_machine.set_process(false)
	state_machine.set_physics_process(false)
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not active:
		return

	match visitor_state:
		VisitorState.ARRIVING:
			_move_toward(perch_position, arrival_distance, true)
			if pigeon.global_position.distance_to(perch_position) <= arrival_distance:
				pigeon.global_position = perch_position
				pigeon.move_direction = Vector2.ZERO
				visitor_state = VisitorState.WAITING
				state_machine.transition(StateMachine.Intent.IDLE)
				_try_next_food()

		VisitorState.WAITING:
			if target_food == null or not is_instance_valid(target_food) or not target_food.visible:
				target_food = null
				_try_next_food()
				if target_food == null:
					pigeon.move_direction = Vector2.ZERO
					state_machine.transition(StateMachine.Intent.IDLE)
					return
			_move_to_food(delta)

		VisitorState.FEEDING:
			pigeon.move_direction = Vector2.ZERO
			state_machine.transition(StateMachine.Intent.IDLE)
			eating_timer -= delta
			if eating_timer <= 0.0:
				var successfully_fed := false
				if is_instance_valid(target_food):
					if target_food.has_method("consume_seed"):
						successfully_fed = bool(target_food.call("consume_seed"))
						if successfully_fed:
							_drop_feather()
					else:
						target_food.hide()
						target_food.queue_free()
						successfully_fed = true
				target_food = null
				if successfully_fed:
					ate_food.emit(food_points)
				visitor_state = VisitorState.DEPARTING
				state_machine.transition(StateMachine.Intent.FLY)

		VisitorState.DEPARTING:
			_move_toward(exit_position, departure_distance, true)
			if pigeon.global_position.distance_to(exit_position) <= departure_distance:
				active = false
				pigeon.hide()
				state_machine.set_process(false)
				state_machine.set_physics_process(false)
				departed.emit()


func _move_to_food(_delta: float) -> void:
	if not _food_is_available(target_food):
		target_food = null
		visitor_state = VisitorState.WAITING
		_try_next_food()
		return

	var distance := pigeon.global_position.distance_to(target_food.global_position)
	if distance <= food_distance:
		pigeon.move_direction = Vector2.ZERO
		state_machine.transition(StateMachine.Intent.IDLE)
		visitor_state = VisitorState.FEEDING
		eating_timer = eating_duration
		return

	_move_toward(target_food.global_position, food_distance, distance > 120.0)


func _move_toward(target: Vector2, stop_distance: float, fly: bool) -> void:
	if pigeon.global_position.distance_to(target) <= stop_distance:
		pigeon.move_direction = Vector2.ZERO
		state_machine.transition(StateMachine.Intent.IDLE)
		return

	pigeon.move_direction = pigeon.global_position.direction_to(target)
	pigeon.update_facing()
	state_machine.transition(StateMachine.Intent.FLY if fly else StateMachine.Intent.WALK)


func _try_next_food() -> void:
	if not active or visitor_state != VisitorState.WAITING or target_food != null:
		return

	while not pending_food.is_empty():
		var next_food: Node2D = pending_food.pop_front() as Node2D
		if not _food_is_available(next_food):
			continue

		target_food = next_food
		return

func _food_is_available(food: Node2D) -> bool:
	if not is_instance_valid(food) or not food.visible:
		return false
	if food.has_method("can_feed"):
		return bool(food.call("can_feed"))
	return true


func _drop_feather() -> void:
	if feather_scene == null or not is_instance_valid(pigeon):
		return
	var feather := feather_scene.instantiate() as Feather
	if feather == null:
		return
	get_tree().current_scene.add_child(feather)
	feather.global_position = pigeon.global_position + Vector2(18.0, 4.0)
