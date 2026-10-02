extends PlayerState
class_name PlayerJumpState

## Jump is currently a visual 2D hop rather than a physics jump.
## The player's collision remains on the ground while the Visuals node moves up.
## The jump animation controls when the state ends.

var time_remaining: float = 0.0
var waiting_for_animation: bool = false
var jump_animation_name: String = ""

func enter_state(previous_state: PlayerState) -> void:
	## Reset the jump timer whenever we enter this state.
	time_remaining = player.JUMP_DURATION

	## The state must remain active until the AnimatedSprite2D finishes
	## the non-looping jump animation.
	jump_animation_name = "jump_" + player.character_visuals.current_direction
	waiting_for_animation = true
	player.character_visuals.sprite.animation_finished.connect(_on_animation_finished)

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
	progress = clamp(progress, 0.0, 1.0)
	var height: float = sin(progress * PI) * player.JUMP_HEIGHT
	player.visuals.position.y = -height

func exit_state() -> void:
	## Disconnect the signal when leaving early so an old animation cannot
	## transition the state machine after Jump has already ended.
	var sprite: AnimatedSprite2D = player.character_visuals.sprite
	if sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.disconnect(_on_animation_finished)

	waiting_for_animation = false
	player.visuals.position.y = 0.0
	player.velocity = Vector2.ZERO

func _on_animation_finished() -> void:
	if not waiting_for_animation:
		return

	var sprite: AnimatedSprite2D = player.character_visuals.sprite
	if sprite.animation != jump_animation_name:
		return

	waiting_for_animation = false
	player.visuals.position.y = 0.0
	player.velocity = Vector2.ZERO
	player.finish_movement_state()
