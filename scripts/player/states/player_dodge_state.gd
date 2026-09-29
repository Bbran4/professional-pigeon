extends PlayerState
class_name PlayerDodgeState

var dodge_direction: Vector2 = Vector2.ZERO
var time_remaining: float = 0.0
var cooldown_remaining: float = 0.0

func enter_state(previous_state: PlayerState) -> void:
	var movement_input: Vector2 = player.get_cardinal_input()

	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	dodge_direction = player.get_isometric_direction(movement_input)
	time_remaining = player.DODGE_DURATION
	player.velocity = dodge_direction * player.DODGE_SPEED

func physics_process_state(delta: float) -> void:
	time_remaining -= delta
	player.velocity = dodge_direction * player.DODGE_SPEED
	player.move_and_slide()

	if time_remaining <= 0.0:
		player.velocity = Vector2.ZERO
		player.finish_movement_state()
