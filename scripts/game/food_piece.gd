extends Node2D
class_name FoodPiece

## A single thrown piece of food on the ground. Feeders own their reserves;
## pigeons claim and consume these individual pieces.

@export_enum("bread", "seeds") var food_kind: String = "bread"
@export var is_golden: bool = false
@export var is_worm: bool = false
@export_range(0.25, 10.0, 0.25) var feeding_duration: float = 1.0

var claimed := false


func _ready() -> void:
	add_to_group("food_pieces")
	z_index = 10
	z_as_relative = false
	_update_visual()


func can_feed() -> bool:
	return is_inside_tree() and is_visible_in_tree() and not claimed


func claim() -> bool:
	if not can_feed():
		return false
	claimed = true
	return true


func consume_food() -> bool:
	if not claimed or not is_inside_tree():
		return false
	queue_free()
	return true


func _update_visual() -> void:
	var visual := get_node_or_null("Visual") as Polygon2D
	if visual == null:
		return
	if food_kind == "seeds":
		visual.color = Color(0.83, 0.68, 0.31, 1.0)
		visual.polygon = PackedVector2Array([Vector2(-5, -2), Vector2(-2, -5), Vector2(2, -2), Vector2(5, 1), Vector2(1, 4), Vector2(-3, 3)])
	else:
		visual.color = Color(0.79, 0.62, 0.39, 1.0)
		visual.polygon = PackedVector2Array([Vector2(-7, -3), Vector2(-4, -6), Vector2(3, -5), Vector2(7, -1), Vector2(5, 4), Vector2(-2, 5), Vector2(-6, 2)])
	if is_golden:
		visual.color = Color(1.0, 0.76, 0.18, 1.0)
	elif is_worm:
		visual.color = Color(0.54, 0.69, 0.3, 1.0)
