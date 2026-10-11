@tool
extends Button
class_name SkillNode

@export var skill_id: StringName
@export var prerequisite_ids: Array[StringName] = []

var skill_tree: SkillTree


func setup(tree: SkillTree) -> void:
	skill_tree = tree
	if not Engine.is_editor_hint() and not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	refresh()


func get_prerequisites() -> Array[StringName]:
	if not prerequisite_ids.is_empty():
		return prerequisite_ids
	if skill_tree == null:
		return []
	var skill := skill_tree.get_skill(skill_id)
	if skill == null:
		return []
	return skill.prerequisites


func refresh() -> void:
	if Engine.is_editor_hint():
		if skill_tree != null:
			var editor_skill := skill_tree.get_skill(skill_id)
			if editor_skill != null:
				text = editor_skill.display_name
				tooltip_text = editor_skill.description
				return
		text = String(skill_id) if skill_id != &"" else "UNASSIGNED"
		return
	if skill_tree == null or skill_id == &"":
		disabled = true
		text = "UNASSIGNED"
		return
	var skill := skill_tree.get_skill(skill_id)
	if skill == null:
		disabled = true
		text = "UNKNOWN SKILL\n" + String(skill_id)
		return

	if skill.coming_soon:
		text = "%s\nCOMING SOON" % skill.display_name
		tooltip_text = skill.description
		disabled = true
		return

	var level := skill_tree.get_level(skill_id)
	var maxed := level >= skill.max_level
	var available := skill_tree.can_purchase(skill_id)
	if maxed:
		text = "%s\nLevel %d/%d\nMAXED" % [
			skill.display_name,
			level,
			skill.max_level
		]
		disabled = true
	else:
		var points_cost := skill_tree.get_next_points_cost(skill_id)
		var cost_text := "%d Feathers" % points_cost
		var state_text := "AVAILABLE"
		if not available:
			if not skill_tree.is_unlocked(skill_id):
				state_text = "PREREQUISITES NEEDED"
			else:
				var lacks_points := ProgressionManager.points < points_cost
				if lacks_points:
					state_text = "NEED %d FEATHERS" % points_cost
				else:
					state_text = "UNAVAILABLE"
		text = "%s\nLevel %d/%d\n%s\n%s" % [
			skill.display_name,
			level,
			skill.max_level,
			cost_text,
			state_text
		]
		disabled = not available
	tooltip_text = skill.description


func _on_pressed() -> void:
	if skill_tree == null:
		return
	if skill_tree.purchase(skill_id):
		refresh()
