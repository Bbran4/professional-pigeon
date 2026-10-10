extends Area2D
class_name Feather

@export var feather_value: int = 1


func _ready() -> void:
	add_to_group("collectible_feathers")
