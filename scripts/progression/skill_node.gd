@tool
extends Button
class_name SkillNode

@export var skill_id: StringName

const NODE_SIZE := Vector2(88.0, 88.0)
const ICONS_BY_EFFECT: Dictionary = {
	&"basic_feeding": "🍞",
	&"unlock_seeds": "🌱",
	&"unlock_worms": "🪱",
	&"max_pigeons": "🐦",
	&"bench_feeder": "🪑",
	&"feather_collect_time_reduction": "🪶",
	&"feather_collect_radius": "⭕",
	&"auto_collect": "🧲",
	&"day_duration_add": "☀️",
	&"arrival_speed_reduction": "💨",
	&"eating_time_reduction": "🌾",
	&"flight_speed_add": "🪽",
	&"feather_wait_reduction": "🪶",
	&"points_per_seed_add": "🌱",
	&"seed_regen_interval": "🌱",
	&"seed_regen_interval_reduction": "🌱",
	&"golden_seed_chance": "✨",
	&"golden_seed_bonus": "✨",
	&"pigeon_patience_add": "🕊️",
	&"rare_visitor_chance": "⭐",
	&"pair_arrivals": "🐦",
	&"bench_count_add": "🪑",
	&"fountain_unlock": "⛲",
	&"tree_nests": "🌳",
	&"feather_count_add": "🪶",
	&"feather_value_add": "💎",
	&"golden_feather_chance": "✨",
	&"crow_collect_interval": "🐦‍⬛",
	&"seed_capacity_add": "🧺",
	&"seeds_spawns": "🌱",
}

var skill_tree: SkillTree


func _ready() -> void:
	custom_minimum_size = NODE_SIZE
	size = NODE_SIZE
	clip_text = true
	add_theme_font_size_override("font_size", 15)


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
		text = String(skill_id) if skill_id != &"" else "UNASSIGNED"
		return
	if skill_tree == null or skill_id == &"":
		disabled = true
		text = "?"
		return
	var skill := skill_tree.get_skill(skill_id)
	if skill == null:
		disabled = true
		text = "?"
		return

	visible = skill_tree.should_show_skill(skill_id)
	if not visible:
		return

	var effect_id: StringName = skill.effect_id
	if not skill.effects.is_empty() and skill.effects[0] != null:
		effect_id = skill.effects[0].effect_id
	var icon := String(ICONS_BY_EFFECT.get(effect_id, "⬆️"))
	var level := SkillPurchases.get_level(skill_id)
	var maxed := level >= skill.max_level
	var costs := SkillPurchases.get_next_currency_costs(skill_id)
	var cost_parts: PackedStringArray = []
	var affordable := true
	for currency_id in costs:
		var amount := int(costs[currency_id])
		var currency_name := String(currency_id).capitalize()
		if currency_id == CurrencyIds.FEATHERS:
			currency_name = "f"
		elif currency_id == CurrencyIds.COINS:
			currency_name = "c"
		cost_parts.append("%d%s" % [amount, currency_name])
		if not ProgressionManager.can_spend_currency(currency_id, amount):
			affordable = false
	var cost_text := ", ".join(cost_parts) if not cost_parts.is_empty() else "Free"
	var current_effect := _format_effect_amount(skill, level)
	var next_effect := _format_effect_amount(skill, mini(level + 1, skill.max_level))
	var effect_text := "%s → %s" % [current_effect, next_effect]
	if skill.coming_soon:
		text = "%s\n—" % icon
		disabled = true
	elif maxed:
		text = "%s\n%d/%d" % [icon, level, skill.max_level]
		disabled = true
	else:
		text = "%s\n%d/%d" % [icon, level, skill.max_level]
		disabled = not SkillPurchases.can_purchase(skill_id)

	var status := ""
	if skill.coming_soon:
		status = "\nCOMING SOON"
	elif maxed:
		status = "\nMAX LEVEL"
	elif not SkillPurchases.is_unlocked(skill_id):
		status = "\nPrerequisites needed"
	elif not affordable:
		status = "\nNot enough currency"
	var tooltip := "%s\n%s\n\nCost: %s\nEffect: %s%s" % [
		skill.display_name,
		skill.description if not skill.description.is_empty() else skill.get_effect_description(),
		"Max level" if maxed else cost_text,
		"—" if skill.coming_soon else effect_text,
		status
	]
	tooltip_text = tooltip


func _format_effect_amount(skill: SkillData, level: int) -> String:
	var effect_id: StringName = skill.effect_id
	var value := skill.effect_value
	if not skill.effects.is_empty() and skill.effects[0] != null:
		effect_id = skill.effects[0].effect_id
		value = skill.effects[0].value
	if level <= 0:
		return "0"
	match effect_id:
		&"max_pigeons", &"feather_count_add", &"feather_value_add", &"bench_count_add", &"seed_capacity_add", &"points_per_seed_add":
			return str(int(round(value * float(level))))
		&"day_duration_add", &"arrival_speed_reduction", &"eating_time_reduction", &"flight_speed_add", &"feather_wait_reduction", &"seed_regen_interval_reduction", &"pigeon_patience_add", &"feather_collect_time_reduction", &"feather_collect_radius":
			return String.num(value * float(level), 2).rstrip("0").rstrip(".")
		&"golden_seed_chance", &"rare_visitor_chance", &"pair_arrivals", &"golden_feather_chance":
			return "%s%%" % String.num(value * float(level) * 100.0, 1)
		_:
			return "Lv. %d" % level


func _on_pressed() -> void:
	if SkillPurchases.purchase(skill_id):
		refresh()
