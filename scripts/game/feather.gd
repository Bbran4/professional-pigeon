extends Collectible
class_name Feather


func _ready() -> void:
	super._ready()
	add_to_group("collectible_feathers")
