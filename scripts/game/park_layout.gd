extends Node
class_name ParkLayout

## Single source of truth for park-space spawn locations and visitor flight bounds.

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
@export var bench_positions: Array[Vector2] = [
	Vector2(300.0, 500.0),
	Vector2(600.0, 500.0),
	Vector2(990.0, 230.0),
]
@export var tree_nest_positions: Array[Vector2] = [
	Vector2(140.0, 155.0),
	Vector2(210.0, 140.0),
	Vector2(245.0, 190.0),
]
@export var fountain_perch_offsets: Array[Vector2] = [
	Vector2(-82.0, 5.0),
	Vector2(82.0, 5.0),
	Vector2(0.0, -65.0),
	Vector2(0.0, 42.0),
]
