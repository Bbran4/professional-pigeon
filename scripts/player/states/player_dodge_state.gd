extends PlayerState
class_name PlayerDodgeState

## Dodge is a short burst of movement in the direction the player is facing.
## The dodge animation controls when the state ends.

var dodge_direction: Vector2 = Vector2.ZERO
var time_remaining: float = 0.0
var cooldown_remaining: float = 0.0
var waiting_for_animation: bool = false
var dodge_animation_name: String = ""

func enter_state(previous_state: PlayerState) -> void:
	## Capture the direction when Dodge begins so the roll keeps a fixed
	## direction even if the player changes input during the roll.
	var movement_input: Vector2 = player.get_cardinal_input()

	if movement_input == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	player.update_facing(movement_input)
	dodge_direction = player.get_isometric_direction(movement_input)
	time_remaining = player.DODGE_DURATION
	player.velocity = dodge_direction * player.DODGE_SPEED

	## The state must remain active until the AnimatedSprite2D finishes
	## the non-looping dodge animation.
	dodge_animation_name = "dodge_" + player.character_visuals.current_direction
	waiting_for_animation = true
	player.character_visuals.sprite.animation_finished.connect(_on_animation_finished)

func physics_process_state(delta: float) -> void:
	## Keep the dodge moving at its fixed speed while the animation plays.
	time_remaining -= delta
	player.velocity = dodge_direction * player.DODGE_SPEED
	player.move_and_slide()

func exit_state() -> void:
	## Disconnect the signal when leaving early so an old animation cannot
	## transition the state machine after Dodge has already ended.
	var sprite: AnimatedSprite2D = player.character_visuals.sprite
	if sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.disconnect(_on_animation_finished)

	waiting_for_animation = false
	player.velocity = Vector2.ZERO

func _on_animation_finished() -> void:
	if not waiting_for_animation:
		return

	var sprite: AnimatedSprite2D = player.character_visuals.sprite
	if sprite.animation != dodge_animation_name:
		return

	waiting_for_animation = false
	player.velocity = Vector2.ZERO
	player.finish_movement_state()
