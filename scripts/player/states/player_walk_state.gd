extends PlayerState
class_name PlayerWalkState

## Walk handles normal movement at WALK_SPEED.
## It can transition to Idle, Run, Dodge, or Jump depending on input.

func physics_process_state(delta: float) -> void:
	## Check special movement requests before ordinary walking.
	if player.consume_dodge_request():
		if player.get_cardinal_input() != Vector2.ZERO:
			state_machine.transition_to(&"Dodge")
			return

	if player.consume_jump_request():
		state_machine.transition_to(&"Jump")
		return

	var movement_input: Vector2 = player.get_cardinal_input()

	if movement_input != Vector2.ZERO:
		player.update_facing(movement_input)

	## Releasing movement returns us to Idle.
	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	## Holding Shift changes Walk into Run.
	if player.is_run_pressed():
		state_machine.transition_to(&"Run")
		return

	## Convert the logical direction into our isometric screen direction.
	var direction: Vector2 = player.get_isometric_direction(movement_input)
	player.move_with_acceleration(direction * player.WALK_SPEED, delta)
	player.move_and_slide()
