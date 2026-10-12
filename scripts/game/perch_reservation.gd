extends RefCounted
class_name PerchReservation

## A unique reservation key paired with a global landing position.
var key: String
var position: Vector2

func _init(p_key: String = "", p_position: Vector2 = Vector2.ZERO) -> void:
	key = p_key
	position = p_position
