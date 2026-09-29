extends PlayerState
class_name PlayerDodgeState

## Dodge is a short burst of movement in the direction the player is facing.
## It owns its own timer because the duration belongs specifically to this state.

var dodge_direction: Vector2 = Vector2.ZERO
var time_remaining: float = 0.0
var cooldown_remaining: float = 0.0

func enter_state(previous_state: PlayerState) -> void:
	## Capture the direction when Dodge begins so the roll keeps a fixed
	## direction even if the player changes input during the roll.
	var movement_input: Vector2 = player.get_cardinal_input()

	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	dodge_direction = player.get_isometric_direction(movement_input)
	time_remaining = player.DODGE_DURATION
	player.velocity = dodge_direction * player.DODGE_SPEED

func physics_process_state(delta: float) -> void:
	## Keep the dodge moving at its fixed speed for the duration.
	time_remaining -= delta
	player.velocity = dodge_direction * player.DODGE_SPEED
	player.move_and_slide()

	## When the roll ends, return control to normal movement.
	if time_remaining <= 0.0:
		player.velocity = Vector2.ZERO
		player.finish_movement_state()
