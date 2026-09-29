extends PlayerState
class_name PlayerWalkState

func physics_process_state(delta: float) -> void:
	if player.consume_dodge_request():
		if player.get_cardinal_input() != Vector2.ZERO:
			state_machine.transition_to(&"Dodge")
			return

	if player.consume_jump_request():
		state_machine.transition_to(&"Jump")
		return

	var movement_input: Vector2 = player.get_cardinal_input()

	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	if player.is_run_pressed():
		state_machine.transition_to(&"Run")
		return

	var direction: Vector2 = player.get_isometric_direction(movement_input)
	player.move_with_acceleration(direction * player.WALK_SPEED, delta)
	player.move_and_slide()
