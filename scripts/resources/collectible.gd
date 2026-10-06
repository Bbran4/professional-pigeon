extends Area2D
class_name Collectible

@export var resource: ResourceData

@onready var visual: Polygon2D = $Visual
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D
@onready var interaction_prompt: Label = $InteractionPrompt

func _ready() -> void:
	_apply_resource_data()
	var key_text := "E"
	var events := InputMap.action_get_events("collect")
	if not events.is_empty():
		key_text = events[0].as_text().get_slice(" ", 0)
	interaction_prompt.text = "Press [%s] to collect" % key_text
	interaction_prompt.hide()

func _apply_resource_data() -> void:
	if resource == null:
		return
	visual.color = resource.visual_color
	visual.polygon = resource.visual_polygon
	collision.polygon = resource.visual_polygon

func set_prompt_visible(is_visible: bool) -> void:
	interaction_prompt.visible = is_visible

func collect() -> void:
	queue_free()

func get_resource_type() -> ResourceData.ResourceType:
	if resource == null:
		return ResourceData.ResourceType.FOOD
	return resource.resource_type

func get_value() -> int:
	if resource == null:
		return 0
	return resource.base_value
