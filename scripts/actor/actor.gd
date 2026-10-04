extends CharacterBody2D
class_name Actor

var move_direction: Vector2 = Vector2.ZERO


func get_move_speed() -> float:
	return 100.0


func move() -> void:
	velocity = move_direction * get_move_speed()
	move_and_slide()


func stop() -> void:
	velocity = Vector2.ZERO
