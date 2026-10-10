extends CharacterBody2D
class_name Actor

var move_direction: Vector2 = Vector2.ZERO


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
