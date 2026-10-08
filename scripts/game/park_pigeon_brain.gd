extends Node
class_name ParkPigeonBrain

signal ate_food(points: int)
signal food_depleted

@export var eating_duration: float = 0.75
@export var food_points: int = 1
@export var food_distance: float = 28.0
@export var fly_away_duration: float = 1.0
@export var fly_away_speed: float = 280.0

var active := false
var target_food: Node2D
var eating_timer := 0.0
var fly_away_timer := 0.0
var returning := false
var perch_position := Vector2.ZERO

@onready var pigeon: Player = get_parent() as Player
@onready var state_machine: StateMachine = $"../StateMachine"

func _ready() -> void:
	state_machine.set_process(false)
	state_machine.set_physics_process(false)

func start_day(perch: Vector2) -> void:
	perch_position = perch
	active = true
	returning = false
	target_food = null
	eating_timer = 0.0
	fly_away_timer = 0.0
	pigeon.global_position = perch_position
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO
	pigeon.flap_held = false
	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	state_machine.transition(StateMachine.Intent.IDLE)

func set_food(food: Node2D) -> void:
	if not active or returning:
		return
	if target_food != null and is_instance_valid(target_food) and target_food.visible:
		return

	target_food = food
	eating_timer = 0.0
	pigeon.try_flap()
	state_machine.transition(StateMachine.Intent.FLY)

func end_day() -> void:
	active = false
	returning = false
	target_food = null
	eating_timer = 0.0
	fly_away_timer = 0.0
	state_machine.set_process(false)
	state_machine.set_physics_process(false)
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO
	pigeon.flap_held = false
	pigeon.global_position = perch_position
	state_machine.transition(StateMachine.Intent.IDLE)

func _physics_process(delta: float) -> void:
	if not active:
		return

	if returning:
		fly_away_timer -= delta
		pigeon.move_direction = Vector2(1.0, 0.0)
		pigeon.flap_held = false
		if fly_away_timer <= 0.0:
			returning = false
			pigeon.global_position = perch_position
			pigeon.velocity = Vector2.ZERO
			pigeon.move_direction = Vector2.ZERO
			state_machine.transition(StateMachine.Intent.IDLE)
		return

	if target_food == null or not is_instance_valid(target_food) or not target_food.visible:
		pigeon.move_direction = Vector2.ZERO
		return

	var distance := pigeon.global_position.distance_to(target_food.global_position)

	if eating_timer > 0.0:
		eating_timer -= delta
		pigeon.move_direction = Vector2.ZERO
		if eating_timer <= 0.0:
			target_food.hide()
			ate_food.emit(food_points)
			food_depleted.emit()
			_start_fly_away()
		return

	if pigeon.is_on_floor():
		pigeon.flap_held = false
		if distance <= food_distance:
			pigeon.move_direction = Vector2.ZERO
			state_machine.transition(StateMachine.Intent.IDLE)
			eating_timer = eating_duration
		else:
			var direction := signf(target_food.global_position.x - pigeon.global_position.x)
			pigeon.move_direction = Vector2(direction, 0.0) if direction != 0.0 else Vector2.ZERO
			pigeon.update_facing()
			state_machine.transition(StateMachine.Intent.WALK)
	else:
		pigeon.flap_held = false
		if state_machine.current_state != null and state_machine.current_state.intent != StateMachine.Intent.FLY and not pigeon.is_diving:
			state_machine.transition(StateMachine.Intent.FALL)

func _start_fly_away() -> void:
	target_food = null
	returning = true
	fly_away_timer = fly_away_duration
	pigeon.move_direction = Vector2(1.0, 0.0)
	pigeon.velocity = Vector2(fly_away_speed, -140.0)
	pigeon.update_facing()
	state_machine.transition(StateMachine.Intent.FLY)
