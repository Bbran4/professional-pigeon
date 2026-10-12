extends Node

## Owns skill prerequisites, scaling costs, purchase validation and transactions.
## UI components query this service and never mutate progression directly.

signal skill_purchased(skill_id: StringName, new_level: int)
signal purchase_rejected(skill_id: StringName, reason: String)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")


func get_skill(skill_id: StringName) -> SkillData:
	for skill in SKILL_CATALOG.skills:
		if skill != null and skill.id == skill_id:
			return skill
	return null


func get_level(skill_id: StringName) -> int:
	return ProgressionManager.get_skill_level(skill_id)


func get_prerequisites(skill_id: StringName) -> Array[StringName]:
	var skill := get_skill(skill_id)
	if skill == null:
		return []
	return skill.prerequisites


func is_unlocked(skill_id: StringName) -> bool:
	if get_skill(skill_id) == null:
		return false
	for prerequisite_id in get_prerequisites(skill_id):
		if get_level(prerequisite_id) <= 0:
			return false
	return true


func get_next_currency_costs(skill_id: StringName) -> Dictionary[StringName, int]:
	var skill := get_skill(skill_id)
	var costs: Dictionary[StringName, int] = {}
	if skill == null:
		return costs
	var growth := pow(maxf(skill.cost_growth, 1.0), get_level(skill_id))
	for currency_id in skill.currency_costs:
		var base_cost := int(skill.currency_costs[currency_id])
		if base_cost < 0:
			continue
		costs[StringName(currency_id)] = ceili(float(base_cost) * growth)
	return costs


func get_purchase_error(skill_id: StringName) -> String:
	var skill := get_skill(skill_id)
	if skill == null:
		return "Skill does not exist."
	if skill.coming_soon:
		return "Skill is coming soon."
	if not is_unlocked(skill_id):
		return "Required skills have not been purchased."
	if get_level(skill_id) >= skill.max_level:
		return "Skill is already at maximum level."
	for currency_id in get_next_currency_costs(skill_id):
		var amount := get_next_currency_costs(skill_id)[currency_id]
		if not ProgressionManager.can_spend_currency(currency_id, amount):
			return "Not enough %s." % _currency_display_name(currency_id)
	return ""


func can_purchase(skill_id: StringName) -> bool:
	return get_purchase_error(skill_id).is_empty()


func purchase(skill_id: StringName) -> bool:
	var error := get_purchase_error(skill_id)
	if not error.is_empty():
		purchase_rejected.emit(skill_id, error)
		return false

	var previously_unlocked := _get_unlocked_skill_ids()
	var costs := get_next_currency_costs(skill_id)
	# Validate every balance before mutating any balance.
	for currency_id in costs:
		if not ProgressionManager.can_spend_currency(currency_id, costs[currency_id]):
			purchase_rejected.emit(skill_id, "Not enough %s." % _currency_display_name(currency_id))
			return false
	for currency_id in costs:
		if not ProgressionManager.spend_currency(currency_id, costs[currency_id]):
			push_error("Skill purchase transaction failed after affordability validation.")
			return false

	var new_level := get_level(skill_id) + 1
	ProgressionManager.set_skill_level(skill_id, new_level)
	for newly_unlocked_id in _get_unlocked_skill_ids():
		if not previously_unlocked.has(newly_unlocked_id):
			DomainEvents.progression_unlocked.emit(newly_unlocked_id)
	ProgressionManager.save_game()
	skill_purchased.emit(skill_id, new_level)
	return true


func _currency_display_name(currency_id: StringName) -> String:
	match currency_id:
		CurrencyIds.FEATHERS:
			return "Feathers"
		CurrencyIds.COINS:
			return "Coins"
		_:
			return String(currency_id).capitalize()


func _get_unlocked_skill_ids() -> Array[StringName]:
	var unlocked: Array[StringName] = []
	for skill in SKILL_CATALOG.skills:
		if skill != null and is_unlocked(skill.id):
			unlocked.append(skill.id)
	return unlocked
