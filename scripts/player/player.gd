extends CharacterBody2D
class_name Player

const WALK_SPEED: float = 120.0
const RUN_SPEED: float = 200.0
const ACCELERATION: float = 900.0
const DECELERATION: float = 1100.0
const DODGE_SPEED: float = 420.0
const DODGE_DURATION: float = 0.22
const DODGE_COOLDOWN: float = 0.35
const JUMP_DURATION: float = 0.42
const JUMP_HEIGHT: float = 22.0

const ISO_UP: Vector2 = Vector2(0.70710678, -0.70710678)
const ISO_RIGHT: Vector2 = Vector2(0.70710678, 0.70710678)
const ISO_DOWN: Vector2 = Vector2(-0.70710678, 0.70710678)
const ISO_LEFT: Vector2 = Vector2(-0.70710678, -0.70710678)

@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var visuals: Polygon2D = $Visuals

var last_cardinal_input: Vector2 = Vector2.DOWN
var dodge_requested: bool = false
var jump_requested: bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	var physical_key: int = event.physical_keycode

	match physical_key:
		KEY_W, KEY_UP:
			last_cardinal_input = Vector2.UP
		KEY_D, KEY_RIGHT:
			last_cardinal_input = Vector2.RIGHT
		KEY_S, KEY_DOWN:
			last_cardinal_input = Vector2.DOWN
		KEY_A, KEY_LEFT:
			last_cardinal_input = Vector2.LEFT
		KEY_SHIFT:
			dodge_requested = true
		KEY_SPACE:
			jump_requested = true

func consume_dodge_request() -> bool:
	if not dodge_requested:
		return false

	dodge_requested = false
	return true

func consume_jump_request() -> bool:
	if not jump_requested:
		return false

	jump_requested = false
	return true

func get_cardinal_input() -> Vector2:
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_direction.y += 1.0

	if input_direction.x != 0.0 and input_direction.y != 0.0:
		if last_cardinal_input.x != 0.0:
			input_direction = Vector2(last_cardinal_input.x, 0.0)
		else:
			input_direction = Vector2(0.0, last_cardinal_input.y)

	return input_direction.normalized()

func get_isometric_direction(cardinal_input: Vector2) -> Vector2:
	if cardinal_input == Vector2.UP:
		return ISO_UP
	if cardinal_input == Vector2.RIGHT:
		return ISO_RIGHT
	if cardinal_input == Vector2.DOWN:
		return ISO_DOWN
	return ISO_LEFT

func is_run_pressed() -> bool:
	return Input.is_physical_key_pressed(KEY_CTRL)

func move_with_acceleration(target_velocity: Vector2, delta: float) -> void:
	var acceleration_rate: float = ACCELERATION if target_velocity != Vector2.ZERO else DECELERATION
	velocity = velocity.move_toward(target_velocity, acceleration_rate * delta)

func finish_movement_state() -> void:
	var movement_input: Vector2 = get_cardinal_input()

	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
	elif is_run_pressed():
		state_machine.transition_to(&"Run")
	else:
		state_machine.transition_to(&"Walk")
