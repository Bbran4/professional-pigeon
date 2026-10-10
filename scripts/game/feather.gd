extends Area2D
class_name Feather

signal collected(feather: Feather)

@export var feather_value: int = 1
@export var collection_radius: float = 30.0

var collection_progress := 0.0


func _ready() -> void:
	add_to_group("collectible_feathers")
	set_process(false)


func add_collection_time(delta: float) -> bool:
	collection_progress += delta
	if collection_progress >= 3.0:
		collected.emit(self)
		return true
	return false


func reset_collection_time() -> void:
	collection_progress = 0.0


func get_collection_progress() -> float:
	return clampf(collection_progress / 3.0, 0.0, 1.0)
