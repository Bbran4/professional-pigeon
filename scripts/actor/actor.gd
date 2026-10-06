extends CharacterBody2D
class_name Actor

@export var gravity_scale: float = 1.0
## Keeps ground-based actors attached to sloped surfaces while walking.
@export var ground_snap_length: float = 8.0

var move_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	floor_snap_length = ground_snap_length
	floor_stop_on_slope = true


func get_move_speed() -> float:
	return 100.0


func move() -> void:
	velocity = move_direction * get_move_speed()
	move_and_slide()


func apply_gravity(delta: float) -> void:
	velocity += get_gravity() * gravity_scale * delta


func stop() -> void:
	velocity = Vector2.ZERO


func play_animation(animation_name: StringName) -> void:
	var animated_sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

	if animated_sprite == null:
		return

	animated_sprite.play(animation_name)


func update_facing() -> void:
	var animated_sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

	if animated_sprite == null:
		return

	if move_direction.x < 0.0:
		animated_sprite.flip_h = true
	elif move_direction.x > 0.0:
		animated_sprite.flip_h = false
