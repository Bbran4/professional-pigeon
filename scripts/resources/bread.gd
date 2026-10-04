extends Area2D
class_name Bread

@export var resource: ResourceData

@onready var interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
	var key_text := "E"
	var events := InputMap.action_get_events("collect")
	if not events.is_empty():
		key_text = events[0].as_text().get_slice(" ", 0)

	interaction_prompt.text = "Press [%s] to collect" % key_text
	interaction_prompt.hide()


func set_prompt_visible(is_visible: bool) -> void:
	interaction_prompt.visible = is_visible


func collect() -> void:
	queue_free()
