extends PlayerState
class_name PlayerJumpState

## Jump is currently a visual 2D hop rather than a physics jump.
## The player's collision remains on the ground while the Visuals node moves up.

var time_remaining: float = 0.0

func enter_state(previous_state: PlayerState) -> void:
	## Reset the jump timer whenever we enter this state.
	time_remaining = player.JUMP_DURATION

func physics_process_state(delta: float) -> void:
	time_remaining -= delta

	var movement_input: Vector2 = player.get_cardinal_input()
	var target_velocity: Vector2 = Vector2.ZERO

	## The player can steer while in the air.
	if movement_input != Vector2.ZERO:
		var direction: Vector2 = player.get_isometric_direction(movement_input)
		target_velocity = direction * player.WALK_SPEED

	player.move_with_acceleration(target_velocity, delta)
	player.move_and_slide()

	## Use a sine curve so the visual rises and falls smoothly.
	var progress: float = 1.0 - (time_remaining / player.JUMP_DURATION)
	var height: float = sin(progress * PI) * player.JUMP_HEIGHT
	player.visuals.position.y = -height

	## Finish the jump and hand control back to normal movement.
	if time_remaining <= 0.0:
		player.visuals.position.y = 0.0
		player.velocity = Vector2.ZERO
		player.finish_movement_state()
