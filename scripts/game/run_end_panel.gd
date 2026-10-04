extends Control

@onready var restart_button: Button = $Panel/RestartButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	var run_manager := get_parent().get_node("RunManager") as RunManager
	if run_manager:
		run_manager.restart_run()
