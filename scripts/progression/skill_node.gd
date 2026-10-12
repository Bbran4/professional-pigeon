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
		# SkillData is not @tool, so editor instances may be placeholders.
		# Keep editor refresh limited to this node's exported data.
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

	if skill.coming_soon:
		text = "%s\nCOMING SOON" % skill.display_name
		TooltipHelper.set_tooltip(self, skill.display_name, skill.get_effect_description())
		disabled = true
		return

	var level := SkillPurchases.get_level(skill_id)
	var maxed := level >= skill.max_level
	var available := SkillPurchases.can_purchase(skill_id)
	if maxed:
		text = "%s\nLevel %d/%d\nMAXED" % [
			skill.display_name,
			level,
			skill.max_level
		]
		disabled = true
	else:
		var costs := SkillPurchases.get_next_currency_costs(skill_id)
		var cost_parts: PackedStringArray = []
		var affordable := true
		for currency_id in costs:
			var amount := int(costs[currency_id])
			var currency_name := String(currency_id).capitalize()
			if currency_id == CurrencyIds.FEATHERS:
				currency_name = "Feathers"
			elif currency_id == CurrencyIds.COINS:
				currency_name = "Coins"
			cost_parts.append("%d %s" % [amount, currency_name])
			if not ProgressionManager.can_spend_currency(currency_id, amount):
				affordable = false
		var cost_text := ", ".join(cost_parts) if not cost_parts.is_empty() else "Free"
		var state_text := "AVAILABLE"
		if not available:
			if not SkillPurchases.is_unlocked(skill_id):
				state_text = "PREREQUISITES NEEDED"
			elif not affordable:
				state_text = "INSUFFICIENT CURRENCY"
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
	TooltipHelper.set_tooltip(self, skill.display_name, skill.get_effect_description())


func _on_pressed() -> void:
	if SkillPurchases.purchase(skill_id):
		refresh()
