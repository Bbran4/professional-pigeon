extends Node
class_name SkillTree

signal skill_purchased(skill_id: StringName, new_level: int)
signal purchase_rejected(skill_id: StringName, reason: String)

@export var catalog: SkillCatalog

var skills: Array[SkillData] = []
var skills_by_id: Dictionary = {}
var _effect_cache: Dictionary = {}


func _ready() -> void:
	if catalog != null:
		skills = catalog.skills
	_rebuild_lookup()
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	_effect_cache.clear()


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
	if _effect_cache.has(effect_id):
		return _effect_cache[effect_id]

	var total := 0.0

	for skill in skills:
		if skill == null or skill.effect_id != effect_id:
			continue
		total += skill.effect_value * get_level(skill.id)

	_effect_cache[effect_id] = total
	return total


func is_unlocked(skill_id: StringName) -> bool:
	var skill := get_skill(skill_id)
	if skill == null:
		return false

	for prerequisite_id in skill.prerequisites:
		if get_level(prerequisite_id) <= 0:
			return false

	return true

func get_next_food_cost(skill_id: StringName) -> int:
	var skill := get_skill(skill_id)
	if skill == null:
		return 0
	return skill.food_cost * (get_level(skill_id) + 1)


func get_next_coin_cost(skill_id: StringName) -> int:
	var skill := get_skill(skill_id)
	if skill == null:
		return 0
	return skill.coin_cost * (get_level(skill_id) + 1)

func _reject(skill_id: StringName, reason: String) -> bool:
	purchase_rejected.emit(skill_id, reason)
	return false
func _get_purchase_error(skill_id: StringName) -> String:
	var skill := get_skill(skill_id)
	if skill == null:
		return "Skill does not exist."
	if not is_unlocked(skill_id):
		return "Required skills have not been purchased."
	if get_level(skill_id) >= skill.max_level:
		return "Skill is already at maximum level."
	if not ProgressionManager.can_spend(get_next_food_cost(skill_id), get_next_coin_cost(skill_id)):
		return "Not enough Food or Coin."
	return ""


func can_purchase(skill_id: StringName) -> bool:
	return _get_purchase_error(skill_id).is_empty()


func purchase(skill_id: StringName) -> bool:
	var error := _get_purchase_error(skill_id)
	if not error.is_empty():
		return _reject(skill_id, error)

	ProgressionManager.spend(get_next_food_cost(skill_id), get_next_coin_cost(skill_id))
	var new_level := get_level(skill_id) + 1
	ProgressionManager.set_skill_level(skill_id, new_level)
	skill_purchased.emit(skill_id, new_level)
	return true
