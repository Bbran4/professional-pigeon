extends Node
class_name ParkLayout

## Single source of truth for visitor flight bounds and fallback landing positions.

@export var visitor_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)
@export var landing_spots: Array[Vector2] = [
	Vector2(780.0, 250.0),
	Vector2(185.0, 112.0),
	Vector2(300.0, 240.0),
	Vector2(450.0, 260.0),
	Vector2(620.0, 460.0),
	Vector2(850.0, 430.0),
	Vector2(1010.0, 250.0),
]
