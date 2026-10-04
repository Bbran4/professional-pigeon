extends Control

@onready var restart_button: Button = $Panel/RestartButton
@onready var upgrades_button: Button = $Panel/UpgradesButton
@onready var upgrade_screen: UpgradeScreen = $"../../UpgradeScreenLayer/UpgradeScreen"


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)


func _on_restart_pressed() -> void:
	var run_manager := get_tree().current_scene.get_node("RunManager") as RunManager
	if run_manager:
		run_manager.restart_run()


func _on_upgrades_pressed() -> void:
	var player := get_tree().current_scene.get_node("Player") as Player
	if player and upgrade_screen:
		upgrade_screen.open(player, self)
