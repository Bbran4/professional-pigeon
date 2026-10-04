extends Node
class_name SkillTree

## Owns purchased skill progress. SkillData resources remain unchanged.

signal skill_purchased(skill_id: StringName, new_level: int)
signal purchase_rejected(skill_id: StringName, reason: String)

@export var catalog: SkillCatalog
@export var inventory: PlayerInventory

var skills: Array[SkillData] = []
var skill_levels: Dictionary = {}
var skills_by_id: Dictionary = {}


func _ready() -> void:
	if catalog != null:
		skills = catalog.skills
	_rebuild_lookup()


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
	return int(skill_levels.get(skill_id, 0))


func get_effect_value(effect_id: StringName) -> float:
	var total := 0.0

	for skill in skills:
		if skill == null or skill.effect_id != effect_id:
			continue
		total += skill.effect_value * get_level(skill.id)

	return total


func is_unlocked(skill_id: StringName) -> bool:
	var skill := get_skill(skill_id)
	if skill == null:
		return false

	for prerequisite_id in skill.prerequisites:
		if get_level(prerequisite_id) <= 0:
			return false

	return true


func can_purchase(skill_id: StringName) -> bool:
	var skill := get_skill(skill_id)
	if skill == null or inventory == null:
		return false
	if not is_unlocked(skill_id):
		return false

	var current_level := get_level(skill_id)
	if current_level >= skill.max_level:
		return false

	var cost := get_next_cost(skill_id)
	return inventory.can_spend_food(cost)


func get_next_cost(skill_id: StringName) -> int:
	var skill := get_skill(skill_id)
	if skill == null:
		return 0

	return skill.food_cost * (get_level(skill_id) + 1)


func purchase(skill_id: StringName) -> bool:
	var skill := get_skill(skill_id)
	if skill == null:
		return _reject(skill_id, "Skill does not exist.")

	if inventory == null:
		return _reject(skill_id, "SkillTree has no inventory assigned.")

	if not is_unlocked(skill_id):
		return _reject(skill_id, "Required skills have not been purchased.")

	var current_level := get_level(skill_id)
	if current_level >= skill.max_level:
		return _reject(skill_id, "Skill is already at maximum level.")

	var cost := get_next_cost(skill_id)
	if not inventory.spend_food(cost):
		return _reject(skill_id, "Not enough Food.")

	var new_level := current_level + 1
	skill_levels[skill_id] = new_level
	skill_purchased.emit(skill_id, new_level)
	return true


func _reject(skill_id: StringName, reason: String) -> bool:
	purchase_rejected.emit(skill_id, reason)
	return false
