extends Area2D
class_name Collectible

@export_range(0, 100000, 1) var point_value: int = 0


func _ready() -> void:
	add_to_group("collectibles")
