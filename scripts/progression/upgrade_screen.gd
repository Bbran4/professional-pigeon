extends Control
class_name UpgradeScreen

signal closed

@onready var food_label: Label = $TopBar/FoodLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var skill_manager: SkillManager = $SkillManager
@onready var back_button: Button = $TopBar/BackButton
@onready var skill_manager: SkillManager = $SkillManager
@onready var source_player: Player = $SkillManager/SkillTree

var skill_tree: SkillTree


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
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


func _on_back_pressed() -> void:
	hide()
	closed.emit()
