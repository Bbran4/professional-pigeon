extends Button
class_name SkillButton

@export var skill_id: StringName

var skill_tree: SkillTree


func setup(tree: SkillTree) -> void:
	skill_tree = tree
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
	var cost := skill_tree.get_next_cost(skill_id)

	if maxed:
		text = "%s\nLevel %d/%d | MAX" % [skill.display_name, level, skill.max_level]
		disabled = true
		return

	text = "%s\nLevel %d/%d | %d Food" % [skill.display_name, level, skill.max_level, cost]
	disabled = not skill_tree.is_unlocked(skill_id) or not skill_tree.can_purchase(skill_id)


func _on_pressed() -> void:
	if skill_tree == null:
		return

	skill_tree.purchase(skill_id)
	refresh()
