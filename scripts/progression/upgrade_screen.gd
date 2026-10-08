extends Control
class_name UpgradeScreen

signal closed

@onready var food_label: Label = $TopBar/FoodLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var skill_manager: SkillManager = $SkillManager
@onready var skill_tree: SkillTree = $SkillManager/SkillTree
@onready var start_day_button: Button = $TopBar/StartDayButton


func _ready() -> void:
	start_day_button.pressed.connect(_on_start_day_pressed)
	ProgressionManager.food_changed.connect(refresh.unbind(1))
	ProgressionManager.coin_changed.connect(refresh.unbind(1))
	refresh()


func open(_player: Player = null) -> void:
	show()
	skill_manager.setup(skill_tree)
	refresh()


func refresh() -> void:
	food_label.text = "Food: %d" % ProgressionManager.food
	coin_label.text = "Coin: %d" % ProgressionManager.coin
	start_day_button.disabled = ProgressionManager.get_skill_level(&"human_feeder") <= 0


func _on_back_pressed() -> void:
	hide()
	closed.emit()


func _on_start_day_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
