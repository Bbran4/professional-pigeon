extends Control
class_name UpgradeScreen

@onready var food_label: Label = $TopBar/FoodLabel
@onready var coin_label: Label = $TopBar/CoinLabel
@onready var skill_manager: SkillManager = $SkillManager
@onready var back_button: Button = $TopBar/BackButton

var skill_tree: SkillTree
var end_panel: Control


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	ProgressionManager.food_changed.connect(refresh.unbind(1))
	ProgressionManager.coin_changed.connect(refresh.unbind(1))
	refresh()


func open(player: Player, run_end_panel: Control) -> void:
	skill_tree = player.get_skill_tree()
	end_panel = run_end_panel
	end_panel.hide()
	skill_manager.setup(skill_tree)
	show()
	refresh()


func refresh() -> void:
	food_label.text = "Food: %d" % ProgressionManager.food
	coin_label.text = "Coin: %d" % ProgressionManager.coin


func _on_back_pressed() -> void:
	hide()
	if end_panel:
		end_panel.show()
