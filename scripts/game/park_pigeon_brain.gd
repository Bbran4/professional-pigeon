extends Node
class_name ParkPigeonBrain

signal ate_food(points: int)

@export var eating_duration: float = 0.75
@export var food_points: int = 1
@export var food_distance: float = 28.0

var active := false
var target_food: Node2D
var eating_timer := 0.0
var perch_position := Vector2.ZERO

@onready var pigeon: Player = get_parent() as Player
@onready var state_machine: StateMachine = $"../StateMachine"

func _ready() -> void:
	state_machine.set_process(false)
	state_machine.set_physics_process(false)

func start_day(food: Node2D, perch: Vector2) -> void:
	target_food = food
	perch_position = perch
	active = true
	eating_timer = 0.0
	pigeon.global_position = perch_position
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO
	pigeon.flap_held = false
	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	pigeon.try_flap()
	state_machine.transition(StateMachine.Intent.FLY)

func end_day() -> void:
	active = false
	state_machine.set_process(false)
	state_machine.set_physics_process(false)
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO
	pigeon.flap_held = false
	pigeon.global_position = perch_position
	state_machine.transition(StateMachine.Intent.IDLE)

func _physics_process(_delta: float) -> void:
	if not active or not is_instance_valid(target_food):
		return

	var distance := pigeon.global_position.distance_to(target_food.global_position)

	if eating_timer > 0.0:
		eating_timer -= _delta
		pigeon.move_direction = Vector2.ZERO
		if eating_timer <= 0.0:
			target_food.hide()
			ate_food.emit(food_points)
			state_machine.transition(StateMachine.Intent.IDLE)
		return

	var direction := signf(target_food.global_position.x - pigeon.global_position.x)
	pigeon.move_direction = Vector2(direction, 0.0) if direction != 0.0 else Vector2.ZERO
	pigeon.update_facing()

	if pigeon.is_on_floor():
		pigeon.flap_held = false
		if distance <= food_distance:
			pigeon.move_direction = Vector2.ZERO
			state_machine.transition(StateMachine.Intent.IDLE)
			eating_timer = eating_duration
		else:
			state_machine.transition(StateMachine.Intent.WALK)
	else:
		pigeon.flap_held = false
		if state_machine.current_state != null and state_machine.current_state.intent != StateMachine.Intent.FLY and not pigeon.is_diving:
			state_machine.transition(StateMachine.Intent.FALL)
