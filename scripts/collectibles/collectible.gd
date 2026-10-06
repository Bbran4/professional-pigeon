extends Area2D
class_name Collectible

@export var data: CollectibleData

@onready var visual: Polygon2D = $Visual
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D
@onready var interaction_prompt: Label = $InteractionPrompt

func _ready() -> void:
	_apply_collectible_data()
	var key_text := "E"
	var events := InputMap.action_get_events("collect")
	if not events.is_empty():
		key_text = events[0].as_text().get_slice(" ", 0)
	interaction_prompt.text = "Press [%s] to collect" % key_text
	interaction_prompt.hide()

func _apply_collectible_data() -> void:
	if data == null:
		return
	visual.color = data.visual_color
	visual.polygon = data.visual_polygon
	collision.polygon = data.visual_polygon

func set_prompt_visible(show_prompt: bool) -> void:
	interaction_prompt.visible = show_prompt

func collect() -> void:
	queue_free()

func get_collectible_type() -> CollectibleData.CollectibleType:
	if data == null:
		return CollectibleData.CollectibleType.FOOD
	return data.collectible_type

func get_value() -> int:
	if data == null:
		return 0
	return data.base_value
