extends CharacterBody2D
class_name Actor

@export var gravity_scale: float = 1.0

var move_direction: Vector2 = Vector2.ZERO


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
