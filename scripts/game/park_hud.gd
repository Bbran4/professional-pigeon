extends CanvasLayer
class_name ParkHud

@onready var day_manager: DayManager = $"../DayManager"
@onready var timer_label: Label = $Margin/Panel/VBox/Timer
@onready var points_label: Label = $Margin/Panel/VBox/Points
@onready var pigeons_label: Label = $Margin/Panel/VBox/Pigeons
@onready var start_button: Button = $StartDay
@onready var result_label: Label = $Result
@onready var upgrades_button: Button = $Upgrades

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
    upgrades_button.pressed.connect(_on_upgrades_pressed)
	day_manager.day_updated.connect(_on_day_updated)
	day_manager.day_ended.connect(_on_day_ended)
	_on_day_updated(0.0, 0, 1)

func _on_upgrades_pressed() -> void:
    var upgrade_screen := get_node_or_null("../UpgradeScreen") as Control
    if upgrade_screen != null:
        upgrade_screen.show()


func _on_start_pressed() -> void:
	day_manager.start_day()
	result_label.hide()
	start_button.hide()

func _on_day_updated(time_remaining: float, points: int, pigeon_count: int) -> void:
	timer_label.text = "Day: %02d" % ceili(time_remaining)
	points_label.text = "Points: %d" % points
	pigeons_label.text = "Pigeons: %d" % pigeon_count
	if not day_manager.active:
		start_button.show()

func _on_day_ended(points: int) -> void:
	result_label.text = "Day complete!  +%d points" % points
	result_label.show()
	start_button.text = "Start Next Day"
	start_button.show()
