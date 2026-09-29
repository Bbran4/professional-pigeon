extends PlayerState
class_name PlayerIdleState

func physics_process_state(delta: float) -> void:
	if player.consume_dodge_request():
		if player.get_cardinal_input() != Vector2.ZERO:
			state_machine.transition_to(&"Dodge")
			return

	if player.consume_jump_request():
		state_machine.transition_to(&"Jump")
		return

	var movement_input: Vector2 = player.get_cardinal_input()

	if movement_input != Vector2.ZERO:
		if player.is_run_pressed():
			state_machine.transition_to(&"Run")
		else:
			state_machine.transition_to(&"Walk")
		return

	player.move_with_acceleration(Vector2.ZERO, delta)
	player.move_and_slide()
