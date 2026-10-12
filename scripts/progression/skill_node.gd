@tool
extends Button
class_name SkillNode

@export var skill_id: StringName

const NODE_SIZE := Vector2(190.0, 100.0)

var skill_tree: SkillTree


func _ready() -> void:
	custom_minimum_size = NODE_SIZE
	size = NODE_SIZE


func setup(tree: SkillTree) -> void:
	skill_tree = tree
	if not Engine.is_editor_hint() and not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	refresh()


func get_prerequisites() -> Array[StringName]:
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
				_apply_category_style(editor_skill)
				text = editor_skill.display_name
				tooltip_text = editor_skill.get_effect_description()
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

	visible = skill_tree.should_show_skill(skill_id)
	if not visible:
		return

	_apply_category_style(skill)
	if skill.coming_soon:
		text = "%s\nCOMING SOON" % skill.display_name
		tooltip_text = skill.get_effect_description()
		disabled = true
		return

	var level := SkillPurchaseService.get_level(skill_id)
	var maxed := level >= skill.max_level
	var available := SkillPurchaseService.can_purchase(skill_id)
	if maxed:
		text = "%s\nLevel %d/%d\nMAXED" % [
			skill.display_name,
			level,
			skill.max_level
		]
		disabled = true
	else:
		var points_cost := SkillPurchaseService.get_next_points_cost(skill_id)
		var cost_text := "%d Feathers" % points_cost
		var state_text := "AVAILABLE"
		if not available:
			if not SkillPurchaseService.is_unlocked(skill_id):
				state_text = "PREREQUISITES NEEDED"
			else:
				var lacks_points := not ProgressionManager.can_spend_points(points_cost)
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
	tooltip_text = skill.get_effect_description()


func _on_pressed() -> void:
	if SkillPurchaseService.purchase(skill_id):
		refresh()


func _apply_category_style(skill: SkillData) -> void:
	var accent := _get_category_color(skill.category)
	var normal := _make_category_style(accent, 0.18)
	var hover := _make_category_style(accent, 0.30)
	var pressed_style := _make_category_style(accent, 0.38)
	var disabled_style := _make_category_style(accent, 0.10)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("disabled", disabled_style)
	add_theme_color_override("font_color", Color(0.94, 0.94, 0.91))
	add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
	add_theme_color_override("font_disabled_color", Color(0.68, 0.68, 0.66))


func _make_category_style(accent: Color, tint: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.10, 0.12).lerp(accent, tint)
	style.border_color = accent
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _get_category_color(category: SkillData.Category) -> Color:
	match category:
		SkillData.Category.FOOD:
			return Color(0.76, 0.57, 0.25)
		SkillData.Category.PLAYER_UPGRADES:
			return Color(0.34, 0.67, 0.83)
		SkillData.Category.ABILITIES:
			return Color(0.63, 0.48, 0.82)
		SkillData.Category.BOOSTS:
			return Color(0.85, 0.47, 0.28)
		SkillData.Category.NPC_PIGEONS:
			return Color(0.43, 0.72, 0.48)
		_:
			return Color(0.55, 0.55, 0.58)
