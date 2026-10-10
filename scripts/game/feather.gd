extends Node2D
class_name Feather

@export_range(1, 100, 1) var coin_value: int = 1


func _ready() -> void:
	add_to_group("feathers")
