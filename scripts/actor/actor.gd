extends CharacterBody2D
class_name Actor

@export var move_speed: float = 100.0

var move_direction: Vector2 = Vector2.ZERO


func move() -> void:
	velocity = move_direction * move_speed
	move_and_slide()


func stop() -> void:
	velocity = Vector2.ZERO
