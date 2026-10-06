extends Control

@onready var restart_button: Button = $Panel/RestartButton
@onready var upgrades_button: Button = $Panel/UpgradesButton
@onready var reason_label: Label = $Panel/ReasonLabel
@onready var food_label: Label = $Panel/FoodLabel
@onready var upgrade_screen: UpgradeScreen = $"../../UpgradeScreenLayer/UpgradeScreen"


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)

	var run_manager := get_tree().current_scene.get_node("RunManager") as RunManager
	if run_manager:
		run_manager.run_ended.connect(_on_run_ended)

	hide()


func _on_run_ended(reason: String, food_collected: int, coin_collected: int) -> void:
	reason_label.text = get_end_reason_text(reason)
	food_label.text = "Food: +%d   |   Coin: +%d" % [food_collected, coin_collected]
	show()


func _on_restart_pressed() -> void:
	var run_manager := get_tree().current_scene.get_node("RunManager") as RunManager
	if run_manager:
		run_manager.restart_run()


func _on_upgrades_pressed() -> void:
	var player := get_tree().current_scene.get_node("Player") as Player
	if player and upgrade_screen:
		upgrade_screen.open(player, self)


func get_end_reason_text(reason: String) -> String:
	if reason == "all_collectibles_collected":
		return "Everything collected!"

	return "Time's up!"
