extends PlayerState
class_name PlayerIdleState

## Idle is the default state.
## The player is not receiving movement input, so this state slows the
## character to a stop and watches for input that should trigger another state.

func physics_process_state(delta: float) -> void:
	## Dodge has priority over normal movement.
	if player.consume_dodge_request():
		if player.get_cardinal_input() != Vector2.ZERO:
			state_machine.transition_to(&"Dodge")
			return

	## Jump is also handled before normal movement.
	if player.consume_jump_request():
		state_machine.transition_to(&"Jump")
		return

	var movement_input: Vector2 = player.get_cardinal_input()

	## Any movement input leaves Idle.
	if movement_input != Vector2.ZERO:
		if player.is_run_pressed():
			state_machine.transition_to(&"Run")
		else:
			state_machine.transition_to(&"Walk")
		return

	## No input means we smoothly decelerate toward zero.
	player.move_with_acceleration(Vector2.ZERO, delta)
	player.move_and_slide()
