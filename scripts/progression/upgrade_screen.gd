extends Control
class_name UpgradeScreen

@onready var food_label: Label = $Panel/VBox/FoodLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var faster_flight_button: Button = $Panel/VBox/FasterFlightButton
@onready var stronger_flaps_button: Button = $Panel/VBox/StrongerFlapsButton
@onready var energy_reserve_button: Button = $Panel/VBox/EnergyReserveButton
@onready var back_button: Button = $Panel/VBox/BackButton

var skill_tree: SkillTree
var end_panel: Control


func _ready() -> void:
	faster_flight_button.pressed.connect(_on_skill_pressed.bind(&"faster_flight"))
	stronger_flaps_button.pressed.connect(_on_skill_pressed.bind(&"stronger_flaps"))
	energy_reserve_button.pressed.connect(_on_skill_pressed.bind(&"energy_reserve"))
	back_button.pressed.connect(_on_back_pressed)
	ProgressionManager.food_changed.connect(_on_progression_changed)
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	refresh()


func open(player: Player, run_end_panel: Control) -> void:
	skill_tree = player.get_skill_tree()
	end_panel = run_end_panel
	end_panel.hide()
	show()
	refresh()


func refresh() -> void:
	food_label.text = "Food: %d" % ProgressionManager.food

	if skill_tree == null:
		return

	_update_skill_button(faster_flight_button, &"faster_flight")
	_update_skill_button(stronger_flaps_button, &"stronger_flaps")
	_update_skill_button(energy_reserve_button, &"energy_reserve")


func _update_skill_button(button: Button, skill_id: StringName) -> void:
	var skill := skill_tree.get_skill(skill_id)
	if skill == null:
		button.disabled = true
		return

	var level := skill_tree.get_level(skill_id)
	var unlocked := skill_tree.is_unlocked(skill_id)
	var maxed := level >= skill.max_level
	var cost := skill_tree.get_next_cost(skill_id)

	if maxed:
		button.text = "%s  |  Level %d/%d  |  MAX" % [skill.display_name, level, skill.max_level]
		button.disabled = true
		return

	button.text = "%s  |  Level %d/%d  |  Cost: %d Food" % [skill.display_name, level, skill.max_level, cost]
	button.disabled = not unlocked or not skill_tree.can_purchase(skill_id)


func _on_skill_pressed(skill_id: StringName) -> void:
	if skill_tree == null:
		return

	if skill_tree.purchase(skill_id):
		status_label.text = "Upgrade purchased."
	else:
		status_label.text = "Upgrade unavailable."
	refresh()


func _on_progression_changed(_food: int) -> void:
	refresh()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	refresh()


func _on_back_pressed() -> void:
	hide()
	if end_panel:
		end_panel.show()
