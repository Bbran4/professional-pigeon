extends Node

## Owns purchased skill levels and derived additive and multiplicative effects.
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var levels: Dictionary = {}
var _effect_totals: Dictionary = {}
var _stat_additions: Dictionary = {}
var _stat_multipliers: Dictionary = {}


func get_skill_level(skill_id: StringName) -> int:
	return int(levels.get(skill_id, 0))


func set_skill_level(skill_id: StringName, level: int) -> void:
	var safe_level := maxi(level, 0)
	if get_skill_level(skill_id) == safe_level:
		return
	levels[skill_id] = safe_level
	_rebuild_effect_totals()
	skill_level_changed.emit(skill_id, safe_level)


## Additive effect lookup retained for existing gameplay systems.
func get_effect_value(effect_id: StringName) -> float:
	return float(_effect_totals.get(effect_id, 0.0))


## Apply all purchased effects targeting a stat to its supplied base value.
## ADD effects accumulate first; MULTIPLY effects then scale the result.
## A MULTIPLY effect value is a per-level factor (for example, 1.1 = +10%).
func get_stat(stat_id: StringName, base_value: float) -> float:
	var value := base_value + float(_stat_additions.get(stat_id, 0.0))
	return value * float(_stat_multipliers.get(stat_id, 1.0))


func load_levels(saved_levels: Dictionary) -> void:
	levels.clear()
	for skill_id in saved_levels:
		levels[StringName(str(skill_id))] = maxi(int(saved_levels[skill_id]), 0)
	_rebuild_effect_totals()


func reset() -> void:
	levels.clear()
	_effect_totals.clear()
	_stat_additions.clear()
	_stat_multipliers.clear()
	for skill in SKILL_CATALOG.skills:
		if skill != null:
			skill_level_changed.emit(skill.id, 0)


func emit_loaded_levels() -> void:
	for skill_id in levels:
		skill_level_changed.emit(skill_id, int(levels[skill_id]))


func _rebuild_effect_totals() -> void:
	_effect_totals.clear()
	_stat_additions.clear()
	_stat_multipliers.clear()
	for skill in SKILL_CATALOG.skills:
		if skill == null:
			continue
		var level := get_skill_level(skill.id)
		if level <= 0:
			continue

		if not skill.effects.is_empty():
			for effect in skill.effects:
				if effect == null:
					continue
				_apply_effect(effect.effect_id, effect.mode, effect.value, level)
		elif skill.effect_id != &"":
			# Backward compatibility for existing skill resources.
			_apply_effect(skill.effect_id, SkillEffect.Mode.ADD, skill.effect_value, level)


func _apply_effect(effect_id: StringName, mode: SkillEffect.Mode, value: float, level: int) -> void:
	match mode:
		SkillEffect.Mode.ADD:
			_effect_totals[effect_id] = float(_effect_totals.get(effect_id, 0.0)) + value * level
			_stat_additions[effect_id] = float(_stat_additions.get(effect_id, 0.0)) + value * level
		SkillEffect.Mode.MULTIPLY:
			_stat_multipliers[effect_id] = float(_stat_multipliers.get(effect_id, 1.0)) * pow(value, level)
