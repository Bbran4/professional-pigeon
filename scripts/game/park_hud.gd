extends CanvasLayer
class_name ParkHud

@onready var day_manager: DayManager = $"../DayManager"
@onready var timer_label: Label = $Margin/Panel/VBox/Timer
@onready var points_label: Label = $Margin/Panel/VBox/Points
@onready var pigeons_label: Label = $Margin/Panel/VBox/Pigeons
@onready var start_button: Button = $StartDay
@onready var result_label: Label = $Result
@onready var unlocks_button: Button = $Upgrades

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	unlocks_button.pressed.connect(_on_unlocks_pressed)
	day_manager.day_updated.connect(_on_day_updated)
	day_manager.day_ended.connect(_on_day_ended)
	_on_day_updated(0.0, 0, 1)

func _on_unlocks_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/progression/upgrade_screen.tscn")

func _on_start_pressed() -> void:
	day_manager.start_day()
	result_label.hide()
	start_button.hide()
	unlocks_button.hide()

func _on_day_updated(time_remaining: float, points: int, pigeon_count: int) -> void:
	timer_label.text = "Day: %02d" % ceili(time_remaining)
	points_label.text = "Points: %d" % points
	pigeons_label.text = "Pigeons: %d" % pigeon_count
	if not day_manager.active:
		start_button.show()
		unlocks_button.show()

func _on_day_ended(points: int) -> void:
	result_label.text = "Day complete!  +%d points" % points
	result_label.show()
	start_button.text = "START NEW DAY"
	start_button.show()
	unlocks_button.text = "UNLOCKS"
	unlocks_button.show()
