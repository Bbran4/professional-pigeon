extends Control
class_name UnlockScreen

const HUMAN_FEEDER_ID: StringName = &"human_feeder"

@onready var status_label: Label = $Panel/VBox/Status
@onready var unlock_button: Button = $Panel/VBox/UnlockButton
@onready var park_button: Button = $Panel/VBox/ParkButton

func _ready() -> void:
	unlock_button.pressed.connect(_on_unlock_pressed)
	park_button.pressed.connect(_on_park_pressed)
	_refresh()

func _refresh() -> void:
	if ProgressionManager.is_unlocked(HUMAN_FEEDER_ID):
		status_label.text = "UNLOCKED\nA human now feeds the pigeons."
		unlock_button.hide()
		park_button.show()
	else:
		status_label.text = "HUMAN FEEDER\nA human will throw bread for the pigeons.\n\nCarry capacity: 2 bread\nCost: FREE"
		unlock_button.show()
		park_button.hide()

func _on_unlock_pressed() -> void:
	ProgressionManager.unlock(HUMAN_FEEDER_ID)
	_refresh()

func _on_park_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
