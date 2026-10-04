extends Area2D
class_name Bread

@export var resource: ResourceData


func collect() -> void:
	queue_free()
