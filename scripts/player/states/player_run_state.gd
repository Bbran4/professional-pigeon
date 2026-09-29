extends PlayerState
class_name PlayerRunState

## Run handles movement at RUN_SPEED while Ctrl is held.
## Releasing Ctrl returns the player to Walk.

func physics_process_state(delta: float) -> void:
	## Special movement requests take priority over running.
	if player.consume_dodge_request():
		if player.get_cardinal_input() != Vector2.ZERO:
			state_machine.transition_to(&"Dodge")
			return

	if player.consume_jump_request():
		state_machine.transition_to(&"Jump")
		return

	var movement_input: Vector2 = player.get_cardinal_input()

	## No movement input means we are no longer running.
	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	## Ctrl being released immediately changes the state to Walk.
	if not player.is_run_pressed():
		state_machine.transition_to(&"Walk")
		return

	var direction: Vector2 = player.get_isometric_direction(movement_input)
	player.move_with_acceleration(direction * player.RUN_SPEED, delta)
	player.move_and_slide()
