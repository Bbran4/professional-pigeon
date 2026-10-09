extends Control
class_name UpgradeScreen

@onready var points_label: Label = $TopBar/PointsLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var start_day_button: Button = $TopBar/StartDayButton


func _ready() -> void:
	start_day_button.pressed.connect(_on_start_day_pressed)
	ProgressionManager.points_changed.connect(refresh.unbind(1))
	ProgressionManager.coin_changed.connect(refresh.unbind(1))
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	refresh()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	refresh()


func refresh() -> void:
	points_label.text = "Points: %d" % ProgressionManager.points
	coin_label.text = "Coin: %d" % ProgressionManager.coin
	start_day_button.disabled = ProgressionManager.get_skill_level(&"bread") <= 0


func _on_start_day_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
