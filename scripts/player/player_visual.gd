extends Node2D
class_name PlayerVisual

const BODY_SIZE := Vector2(24.0, 40.0)
const BODY_COLOR := Color("#2388ff")

func _draw() -> void:
	draw_rect(
		Rect2(-BODY_SIZE * 0.5, BODY_SIZE),
		BODY_COLOR,
		true
	)
