extends Collectible
class_name Feather

@export var feather_value: int:
	get:
		return coin_value
	set(value):
		coin_value = value


func _ready() -> void:
	super._ready()
	add_to_group("collectible_feathers")
