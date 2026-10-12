extends Collectible
class_name Feather

const NORMAL_COLOR := Color(0.92, 0.9, 0.78, 1.0)
const GOLDEN_COLOR := Color(1.0, 0.72, 0.12, 1.0)

var is_golden := false


func _ready() -> void:
	super._ready()
	add_to_group("collectible_feathers")
	_update_visual()


func set_golden(value: bool) -> void:
	is_golden = value
	_update_visual()


func _update_visual() -> void:
	var visual := get_node_or_null("Visual") as Polygon2D
	if visual != null:
		visual.color = GOLDEN_COLOR if is_golden else NORMAL_COLOR
