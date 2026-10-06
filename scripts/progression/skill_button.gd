extends Button
class_name SkillButton

@export var skill_id: StringName

var skill_tree: SkillTree


func setup(tree: SkillTree) -> void:
	skill_tree = tree
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	refresh()


func refresh() -> void:
	if skill_tree == null or skill_id == &"":
		disabled = true
		return

	var skill := skill_tree.get_skill(skill_id)
	if skill == null:
		disabled = true
		return

	var level := skill_tree.get_level(skill_id)
	var maxed := level >= skill.max_level
	var food_cost := skill_tree.get_next_food_cost(skill_id)
	var coin_cost := skill_tree.get_next_coin_cost(skill_id)

	if maxed:
		text = "%s\nLevel %d/%d | MAX" % [skill.display_name, level, skill.max_level]
		disabled = true
		return

	var cost_text := "%d Food" % food_cost
	if coin_cost > 0:
		cost_text += " + %d Coin" % coin_cost

	text = "%s\nLevel %d/%d | %s" % [skill.display_name, level, skill.max_level, cost_text]
	disabled = not skill_tree.can_purchase(skill_id)


func _on_pressed() -> void:
	if skill_tree == null:
		return
	skill_tree.purchase(skill_id)
	refresh()
