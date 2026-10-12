@tool
extends Control
class_name SkillTree

signal skill_purchased(skill_id: StringName, new_level: int)
signal purchase_rejected(skill_id: StringName, reason: String)

@export var catalog: SkillCatalog
@export var skill_node_scene: PackedScene = preload("res://scenes/progression/skill_node.tscn")
@export var connection_width: float = 6.0
@export var connection_color: Color = Color(0.45, 0.45, 0.5, 0.8)
@export var locked_connection_color: Color = Color(0.25, 0.25, 0.28, 0.7)
@export var purchased_connection_color: Color = Color(0.75, 0.6, 0.2, 0.95)

var skills: Array[SkillData] = []
var skills_by_id: Dictionary = {}
var nodes_by_id: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_catalog()
	_collect_nodes()
	if Engine.is_editor_hint():
		queue_redraw()
		return
	_connect_progression_signals()
	queue_redraw()


func _load_catalog() -> void:
	skills.clear()
	if catalog != null:
		assert(catalog.validate(), "SkillTree requires a valid SkillCatalog.")
		skills = catalog.skills
	_rebuild_lookup()


func _connect_progression_signals() -> void:
	if ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		return
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	_refresh_nodes()
	queue_redraw()


func _collect_nodes() -> void:
	nodes_by_id.clear()
	for child in get_children():
		var node := child as SkillNode
		if node == null:
			continue
		assert(node.skill_id != &"", "SkillTree node '%s' has an empty skill ID." % node.name)
		assert(get_skill(node.skill_id) != null, "SkillTree node '%s' has no matching SkillCatalog entry." % node.name)
		assert(not nodes_by_id.has(node.skill_id), "SkillTree contains duplicate node ID '%s'." % node.skill_id)
		nodes_by_id[node.skill_id] = node
		if not node.item_rect_changed.is_connected(queue_redraw):
			node.item_rect_changed.connect(queue_redraw)
		node.setup(self)

func _refresh_nodes() -> void:
	for child in get_children():
		var node := child as SkillNode
		if node != null:
			node.refresh()


func _rebuild_lookup() -> void:
	skills_by_id.clear()
	for skill in skills:
		if skill == null:
			continue
		if skill.id == &"":
			push_warning("SkillTree contains a skill with an empty ID.")
			continue
		if skills_by_id.has(skill.id):
			push_warning("Duplicate skill ID in SkillTree: " + String(skill.id))
			continue
		skills_by_id[skill.id] = skill


func get_skill(skill_id: StringName) -> SkillData:
	return skills_by_id.get(skill_id) as SkillData


func get_level(skill_id: StringName) -> int:
	return ProgressionManager.get_skill_level(skill_id)


func get_effect_value(effect_id: StringName) -> float:
	return ProgressionManager.get_effect_value(effect_id)


func get_prerequisites(skill_id: StringName) -> Array[StringName]:
	var skill := get_skill(skill_id)
	if skill == null:
		return []
	return skill.prerequisites

func is_unlocked(skill_id: StringName) -> bool:
	var skill := get_skill(skill_id)
	if skill == null:
		return false
	for prerequisite_id in get_prerequisites(skill_id):
		if get_level(prerequisite_id) <= 0:
			return false
	return true


func get_next_points_cost(skill_id: StringName) -> int:
	var skill := get_skill(skill_id)
	if skill == null:
		return 0
	return _get_scaled_cost(skill.points_cost, skill.cost_growth, get_level(skill_id))


func _get_scaled_cost(base_cost: int, growth: float, current_level: int) -> int:
	if base_cost <= 0:
		return 0
	return ceili(float(base_cost) * pow(maxf(growth, 1.0), current_level))


func _get_purchase_error(skill_id: StringName) -> String:
	var skill := get_skill(skill_id)
	if skill == null:
		return "Skill does not exist."
	if not is_unlocked(skill_id):
		return "Required skills have not been purchased."
	if get_level(skill_id) >= skill.max_level:
		return "Skill is already at maximum level."
	if not ProgressionManager.can_spend_points(get_next_points_cost(skill_id)):
		return "Not enough Feathers."
	return ""


func can_purchase(skill_id: StringName) -> bool:
	return _get_purchase_error(skill_id).is_empty()


func purchase(skill_id: StringName) -> bool:
	var error := _get_purchase_error(skill_id)
	if not error.is_empty():
		purchase_rejected.emit(skill_id, error)
		return false
	ProgressionManager.spend_points(get_next_points_cost(skill_id))
	var new_level := get_level(skill_id) + 1
	ProgressionManager.set_skill_level(skill_id, new_level)
	ProgressionManager.save_game()
	skill_purchased.emit(skill_id, new_level)
	return true


func _draw() -> void:
	if Engine.is_editor_hint():
		for child in get_children():
			var editor_node := child as SkillNode
			if editor_node == null:
				continue
			var editor_skill := get_skill(editor_node.skill_id)
			if editor_skill == null:
				continue
			var editor_from := editor_node.position + editor_node.size * 0.5
			for prerequisite_id in editor_node.get_prerequisites():
				var editor_prerequisite := nodes_by_id.get(prerequisite_id) as SkillNode
				if editor_prerequisite == null:
					continue
				var editor_to := editor_prerequisite.position + editor_prerequisite.size * 0.5
				draw_line(editor_from, editor_to, connection_color, connection_width, true)
		return
	for child in get_children():
		var node := child as SkillNode
		if node == null:
			continue
		var from_position := node.position + node.size * 0.5
		for prerequisite_id in node.get_prerequisites():
			var prerequisite := nodes_by_id.get(prerequisite_id) as SkillNode
			if prerequisite == null:
				continue
			var to_position := prerequisite.position + prerequisite.size * 0.5
			var purchased := get_level(prerequisite_id) > 0 and get_level(node.skill_id) > 0
			var available := is_unlocked(node.skill_id)
			var line_color := locked_connection_color
			if purchased:
				line_color = purchased_connection_color
			elif available:
				line_color = connection_color
			draw_line(from_position, to_position, line_color, connection_width, true)
