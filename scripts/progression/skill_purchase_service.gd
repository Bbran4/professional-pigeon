extends Node
class_name SkillPurchaseService

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


func get_next_points_cost(skill_id: StringName) -> int:
	var skill := get_skill(skill_id)
	if skill == null:
		return 0
	if skill.points_cost <= 0:
		return 0
	return ceili(float(skill.points_cost) * pow(maxf(skill.cost_growth, 1.0), get_level(skill_id)))


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
	if not ProgressionManager.can_spend_points(get_next_points_cost(skill_id)):
		return "Not enough Feathers."
	return ""


func can_purchase(skill_id: StringName) -> bool:
	return get_purchase_error(skill_id).is_empty()


func purchase(skill_id: StringName) -> bool:
	var error := get_purchase_error(skill_id)
	if not error.is_empty():
		purchase_rejected.emit(skill_id, error)
		return false

	var cost := get_next_points_cost(skill_id)
	if not ProgressionManager.spend_points(cost):
		purchase_rejected.emit(skill_id, "Not enough Feathers.")
		return false

	var new_level := get_level(skill_id) + 1
	ProgressionManager.set_skill_level(skill_id, new_level)
	ProgressionManager.save_game()
	skill_purchased.emit(skill_id, new_level)
	return true
