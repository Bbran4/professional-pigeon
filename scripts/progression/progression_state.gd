extends Node

## Owns purchased skill levels and derived additive effect totals.
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var levels: Dictionary = {}
var _effect_totals: Dictionary = {}


func get_skill_level(skill_id: StringName) -> int:
	return int(levels.get(skill_id, 0))


func set_skill_level(skill_id: StringName, level: int) -> void:
	var safe_level := maxi(level, 0)
	if get_skill_level(skill_id) == safe_level:
		return
	levels[skill_id] = safe_level
	_rebuild_effect_totals()
	skill_level_changed.emit(skill_id, safe_level)


func get_effect_value(effect_id: StringName) -> float:
	return float(_effect_totals.get(effect_id, 0.0))


func load_levels(saved_levels: Dictionary) -> void:
	levels.clear()
	for skill_id in saved_levels:
		levels[StringName(str(skill_id))] = maxi(int(saved_levels[skill_id]), 0)
	_rebuild_effect_totals()


func reset() -> void:
	levels.clear()
	_effect_totals.clear()
	for skill in SKILL_CATALOG.skills:
		if skill != null:
			skill_level_changed.emit(skill.id, 0)


func emit_loaded_levels() -> void:
	for skill_id in levels:
		skill_level_changed.emit(skill_id, int(levels[skill_id]))


func _rebuild_effect_totals() -> void:
	_effect_totals.clear()
	for skill in SKILL_CATALOG.skills:
		if skill == null or skill.effect_id == &"":
			continue
		var level := get_skill_level(skill.id)
		if level <= 0:
			continue
		var current_total := float(_effect_totals.get(skill.effect_id, 0.0))
		_effect_totals[skill.effect_id] = current_total + skill.effect_value * level
