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
@onready var visuals: Node2D = $Visuals

var last_cardinal_input: Vector2 = Vector2.DOWN
var dodge_direction: Vector2 = Vector2.ZERO
var dodge_time_remaining: float = 0.0
var dodge_cooldown_remaining: float = 0.0
var jump_time_remaining: float = 0.0
var dodge_requested: bool = false
var jump_requested: bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	state_machine.change_state(PlayerStateMachine.State.IDLE)

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	var physical_key: Key = event.physical_keycode

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

func _physics_process(delta: float) -> void:
	dodge_cooldown_remaining = maxf(dodge_cooldown_remaining - delta, 0.0)

	match state_machine.current_state:
		PlayerStateMachine.State.IDLE, PlayerStateMachine.State.WALK, PlayerStateMachine.State.RUN:
			_process_grounded(delta)
		PlayerStateMachine.State.DODGE:
			_process_dodge(delta)
		PlayerStateMachine.State.JUMP:
			_process_jump(delta)

	move_and_slide()
	_update_visual_offset()

func _process_grounded(delta: float) -> void:
	var movement_input: Vector2 = _get_cardinal_input()

	if dodge_requested:
		dodge_requested = false
		if dodge_cooldown_remaining <= 0.0 and movement_input != Vector2.ZERO:
			dodge_direction = _to_isometric_direction(movement_input)
			dodge_time_remaining = DODGE_DURATION
			dodge_cooldown_remaining = DODGE_COOLDOWN
			state_machine.change_state(PlayerStateMachine.State.DODGE)
			velocity = dodge_direction * DODGE_SPEED
			return

	if jump_requested:
		jump_requested = false
		jump_time_remaining = JUMP_DURATION
		state_machine.change_state(PlayerStateMachine.State.JUMP)
		return

	var target_speed: float = RUN_SPEED if Input.is_physical_key_pressed(KEY_CTRL) else WALK_SPEED
	var target_velocity: Vector2 = Vector2.ZERO

	if movement_input != Vector2.ZERO:
		target_velocity = _to_isometric_direction(movement_input) * target_speed
		var target_state: int = PlayerStateMachine.State.RUN if target_speed == RUN_SPEED else PlayerStateMachine.State.WALK
		state_machine.change_state(target_state)
	else:
		state_machine.change_state(PlayerStateMachine.State.IDLE)

	var rate: float = ACCELERATION if movement_input != Vector2.ZERO else DECELERATION
	velocity = velocity.move_toward(target_velocity, rate * delta)

func _process_dodge(delta: float) -> void:
	dodge_time_remaining -= delta
	velocity = dodge_direction * DODGE_SPEED
	if dodge_time_remaining <= 0.0:
		_state_from_current_input()

func _process_jump(delta: float) -> void:
	jump_time_remaining -= delta
	var movement_input: Vector2 = _get_cardinal_input()
	var target_velocity: Vector2 = Vector2.ZERO

	if movement_input != Vector2.ZERO:
		target_velocity = _to_isometric_direction(movement_input) * WALK_SPEED

	velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)

	if jump_time_remaining <= 0.0:
		_state_from_current_input()

func _state_from_current_input() -> void:
	var movement_input: Vector2 = _get_cardinal_input()

	if movement_input == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * get_physics_process_delta_time())
		state_machine.change_state(PlayerStateMachine.State.IDLE)
	elif Input.is_physical_key_pressed(KEY_CTRL):
		state_machine.change_state(PlayerStateMachine.State.RUN)
	else:
		state_machine.change_state(PlayerStateMachine.State.WALK)

func _get_cardinal_input() -> Vector2:
	var input: Vector2 = Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input.y += 1.0

	if input.x != 0.0 and input.y != 0.0:
		if last_cardinal_input.x != 0.0:
			input = Vector2(last_cardinal_input.x, 0.0)
		else:
			input = Vector2(0.0, last_cardinal_input.y)

	return input.normalized()

func _to_isometric_direction(cardinal_input: Vector2) -> Vector2:
	if cardinal_input == Vector2.UP:
		return ISO_UP
	if cardinal_input == Vector2.RIGHT:
		return ISO_RIGHT
	if cardinal_input == Vector2.DOWN:
		return ISO_DOWN
	return ISO_LEFT

func _update_visual_offset() -> void:
	if state_machine.is_state(PlayerStateMachine.State.JUMP):
		var progress: float = 1.0 - (jump_time_remaining / JUMP_DURATION)
		var height: float = sin(progress * PI) * JUMP_HEIGHT
		visuals.position.y = -height
	else:
		visuals.position.y = 0.0
