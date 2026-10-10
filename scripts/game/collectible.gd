extends Area2D
class_name Collectible

@export_range(0, 100000, 1) var coin_value: int = 1


func _ready() -> void:
	add_to_group("collectibles")
