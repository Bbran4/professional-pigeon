extends CharacterBody2D
class_name Player

## The Player is the shared interface used by the individual movement states.
## It owns input, movement constants, and helper functions.
## The actual behaviour for Idle, Walk, Run, Dodge, and Jump lives in
## the separate state scripts under scripts/player/states/.

const WALK_SPEED: float = 120.0
const RUN_SPEED: float = 200.0
const ACCELERATION: float = 900.0
const DECELERATION: float = 1100.0
const DODGE_SPEED: float = 420.0
const DODGE_DURATION: float = 0.22
const DODGE_COOLDOWN: float = 0.35
const JUMP_DURATION: float = 0.42
const JUMP_HEIGHT: float = 22.0

@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var visuals: Node2D = $Visuals
@onready var character_visuals: CharacterVisuals = $Visuals/CharacterVisuals
@onready var state_label: Label = $StateLabel

## Input is recorded here and consumed by states when appropriate.
var last_cardinal_input: Vector2 = Vector2.DOWN
var dodge_requested: bool = false
var jump_requested: bool = false
var facing_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	## CharacterBody2D normally has floor-based movement in 2D.
	## Floating mode is appropriate for our top-down/isometric movement.
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	## The state machine emits this whenever the active state changes.
	state_machine.state_changed.connect(_on_state_changed)

	## The initial state is entered by the state machine before this node's
	## _ready() runs, so update the label once here as well.
	_update_state_label()

func _input(event: InputEvent) -> void:
	## We only care about keyboard input for this prototype.
	if event is not InputEventKey:
		return

	## Ignore key releases and keyboard auto-repeat.
	if not event.pressed or event.echo:
		return

	var physical_key: int = event.physical_keycode

	## Remember the most recently pressed cardinal direction.
	## This is used when two movement keys are held at the same time.
	match physical_key:
		KEY_W, KEY_UP:
			last_cardinal_input = Vector2.UP
		KEY_D, KEY_RIGHT:
			last_cardinal_input = Vector2.RIGHT
		KEY_S, KEY_DOWN:
			last_cardinal_input = Vector2.DOWN
		KEY_A, KEY_LEFT:
			last_cardinal_input = Vector2.LEFT
		KEY_CTRL:
			dodge_requested = true
		KEY_SPACE:
			jump_requested = true

func consume_dodge_request() -> bool:
	## States call this when they want to check for a dodge request.
	## Consuming it means the request is handled only once.
	if not dodge_requested:
		return false

	dodge_requested = false
	return true

func consume_jump_request() -> bool:
	## Same idea as consume_dodge_request(), but for jumping.
	if not jump_requested:
		return false

	jump_requested = false
	return true

func get_cardinal_input() -> Vector2:
	## Read the current WASD/arrow-key movement input.
	## The returned value is always one of the four cardinal directions,
	## or Vector2.ZERO when there is no movement input.
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_direction.y += 1.0

	## Holding two directions combines both axes, so diagonal movement is possible.
	return input_direction.normalized()

func get_isometric_direction(cardinal_input: Vector2) -> Vector2:
	## Movement uses normal screen-space coordinates.
	## The isometric presentation comes from the world and art, not by
	## changing the player's X/Y movement axes.
	return cardinal_input

func is_run_pressed() -> bool:
	## Shift is the temporary prototype run modifier.
	return Input.is_physical_key_pressed(KEY_SHIFT)

func update_facing(cardinal_input: Vector2) -> void:
	if cardinal_input == Vector2.ZERO:
		return

	var face_direction: Vector2 = cardinal_input

	## When moving diagonally, use the most recently pressed cardinal
	## direction for the character's facing. Movement still uses both axes.
	if cardinal_input.x != 0.0 and cardinal_input.y != 0.0:
		face_direction = last_cardinal_input

	facing_direction = face_direction
	character_visuals.update_direction(facing_direction)

func move_with_acceleration(target_velocity: Vector2, delta: float) -> void:
	## States ask the Player to move toward a target velocity.
	## Keeping acceleration here means every movement state uses the same
	## movement feel without duplicating the math.
	var acceleration_rate: float = ACCELERATION if target_velocity != Vector2.ZERO else DECELERATION
	velocity = velocity.move_toward(target_velocity, acceleration_rate * delta)

func finish_movement_state() -> void:
	## Dodge and Jump call this when they finish.
	## We then decide which normal movement state should take over.
	var movement_input: Vector2 = get_cardinal_input()

	if movement_input != Vector2.ZERO:
		update_facing(movement_input)

	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
	elif is_run_pressed():
		state_machine.transition_to(&"Run")
	else:
		state_machine.transition_to(&"Walk")

func _on_state_changed(previous_state: PlayerState, new_state: PlayerState) -> void:
	## Update the debug label whenever the state machine changes state.
	_update_state_label()

func _update_state_label() -> void:
	## Display the actual state node name above the player.
	if state_machine.current_state == null:
		state_label.text = "No State"
		return

	state_label.text = String(state_machine.current_state.name)
