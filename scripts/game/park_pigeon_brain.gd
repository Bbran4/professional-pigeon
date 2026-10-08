extends Node
class_name ParkPigeonBrain

signal ate_food(points: int)
signal food_depleted

@export var eating_duration: float = 0.75
@export var food_points: int = 1
@export var food_distance: float = 28.0
@export var return_distance: float = 18.0
@export var park_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)

var active := false
var target_food: Node2D
var pending_food: Array[Node2D] = []
var eating_timer := 0.0
var returning := false
var perch_position := Vector2.ZERO

@onready var pigeon: Pigeon = get_parent() as Pigeon
@onready var state_machine: StateMachine = $"../StateMachine"


func _ready() -> void:
	state_machine.set_process(false)
	state_machine.set_physics_process(false)


func start_day(perch: Vector2) -> void:
	perch_position = perch
	active = true
	returning = false
	target_food = null
	pending_food.clear()
	eating_timer = 0.0

	pigeon.show()
	pigeon.global_position = perch_position
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO

	state_machine.set_process(false)
	state_machine.set_physics_process(false)
	state_machine.transition(StateMachine.Intent.IDLE)


func set_food(food: Node2D) -> void:
	if not active:
		return
	if food == null or not is_instance_valid(food):
		return

	pending_food.append(food)
	_try_next_food()


func end_day() -> void:
	active = false
	returning = false
	target_food = null
	pending_food.clear()
	eating_timer = 0.0

	state_machine.set_process(false)
	state_machine.set_physics_process(false)

	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO
	pigeon.global_position = perch_position
	pigeon.show()


func _physics_process(delta: float) -> void:
	if not active:
		return

	if returning:
		_return_to_perch(delta)
		return

	if target_food == null or not is_instance_valid(target_food) or not target_food.visible:
		target_food = null
		_try_next_food()
		return

	var distance := pigeon.global_position.distance_to(target_food.global_position)

	if eating_timer > 0.0:
		eating_timer -= delta
		pigeon.move_direction = Vector2.ZERO
		if eating_timer <= 0.0:
			target_food.hide()
			target_food.queue_free()
			ate_food.emit(food_points)
			food_depleted.emit()
			target_food = null
			returning = true
			state_machine.transition(StateMachine.Intent.FLY)
		return

	var direction := pigeon.global_position.direction_to(target_food.global_position)

	if distance <= food_distance:
		pigeon.move_direction = Vector2.ZERO
		state_machine.transition(StateMachine.Intent.IDLE)
		eating_timer = eating_duration
		return

	pigeon.move_direction = direction
	pigeon.update_facing()

	if distance > 120.0:
		state_machine.transition(StateMachine.Intent.FLY)
	else:
		state_machine.transition(StateMachine.Intent.WALK)


func _return_to_perch(_delta: float) -> void:
	var distance := pigeon.global_position.distance_to(perch_position)

	if distance <= return_distance:
		returning = false
		pigeon.global_position = perch_position
		pigeon.velocity = Vector2.ZERO
		pigeon.move_direction = Vector2.ZERO
		pigeon.hide()
		state_machine.set_process(false)
		state_machine.set_physics_process(false)
		_try_next_food()
		return

	pigeon.move_direction = pigeon.global_position.direction_to(perch_position)
	pigeon.update_facing()
	state_machine.transition(StateMachine.Intent.FLY)


func _try_next_food() -> void:
	if not active or returning or target_food != null:
		return

	while not pending_food.is_empty():
		var next_food: Node2D = pending_food.pop_front() as Node2D
		if not is_instance_valid(next_food) or not next_food.visible:
			continue

		target_food = next_food
		eating_timer = 0.0

		pigeon.show()
		if pigeon.global_position == perch_position:
			pigeon.global_position = perch_position

		state_machine.set_process(true)
		state_machine.set_physics_process(true)
		state_machine.transition(StateMachine.Intent.FLY)
		return
