extends Resource
class_name SkillCatalog

## Collection of static skill definitions shared by the progression system.

@export var skills: Array[SkillData] = []


## Validate skill IDs, effect IDs, prerequisites, values, and dependency cycles.
## Returns true only when the entire catalog is structurally valid.
func validate() -> bool:
	var valid := true
	var skills_by_id: Dictionary = {}

	for skill in skills:
		if skill == null:
			push_error("SkillCatalog: catalog contains a null skill entry.")
			valid = false
			continue

		if skill.id == &"":
			push_error("SkillCatalog: skill '%s' has an empty ID." % skill.display_name)
			valid = false
			continue

		if skills_by_id.has(skill.id):
			push_error("SkillCatalog: duplicate skill ID '%s'." % skill.id)
			valid = false
		else:
			skills_by_id[skill.id] = skill

		if skill.display_name.strip_edges().is_empty():
			push_error("SkillCatalog: skill '%s' has an empty display name." % skill.id)
			valid = false
		if skill.category < SkillData.Category.FOOD or skill.category > SkillData.Category.NPC_PIGEONS:
			push_error("SkillCatalog: skill '%s' has an invalid category value %d." % [skill.id, skill.category])
			valid = false
		if skill.points_cost < 0:
			push_error("SkillCatalog: skill '%s' has a negative points cost." % skill.id)
			valid = false
		if not is_finite(skill.cost_growth) or skill.cost_growth < 1.0:
			push_error("SkillCatalog: skill '%s' has invalid cost growth %s; expected a finite value >= 1." % [skill.id, skill.cost_growth])
			valid = false
		if skill.max_level < 1:
			push_error("SkillCatalog: skill '%s' has max_level < 1." % skill.id)
			valid = false
		if not is_finite(skill.effect_value):
			push_error("SkillCatalog: skill '%s' has a non-finite effect value." % skill.id)
			valid = false
		if skill.effect_id == &"":
			if not skill.coming_soon:
				push_error("SkillCatalog: skill '%s' has no effect ID." % skill.id)
				valid = false
		elif not EffectIds.is_valid_id(skill.effect_id):
			push_error("SkillCatalog: skill '%s' uses unknown effect ID '%s'." % [skill.id, skill.effect_id])
			valid = false

		var seen_prerequisites: Dictionary = {}
		for prerequisite in skill.prerequisites:
			if prerequisite == skill.id:
				push_error("SkillCatalog: skill '%s' cannot require itself." % skill.id)
				valid = false
			if seen_prerequisites.has(prerequisite):
				push_error("SkillCatalog: skill '%s' lists prerequisite '%s' more than once." % [skill.id, prerequisite])
				valid = false
			seen_prerequisites[prerequisite] = true

	for skill in skills:
		if skill == null:
			continue
		for prerequisite in skill.prerequisites:
			if not skills_by_id.has(prerequisite):
				push_error(
					"SkillCatalog: skill '%s' references missing prerequisite '%s'."
					% [skill.id, prerequisite]
				)
				valid = false

	var visit_states: Dictionary = {}
	for skill in skills:
		if skill == null or skill.id == &"" or not skills_by_id.has(skill.id):
			continue
		if _has_dependency_cycle(skill.id, skills_by_id, visit_states):
			push_error("SkillCatalog: dependency cycle detected involving skill '%s'." % skill.id)
			valid = false
			break

	return valid


## Depth-first search: 1 means visiting, 2 means fully checked.
func _has_dependency_cycle(
	skill_id: StringName,
	skills_by_id: Dictionary,
	visit_states: Dictionary
) -> bool:
	var state := int(visit_states.get(skill_id, 0))
	if state == 1:
		return true
	if state == 2:
		return false

	visit_states[skill_id] = 1
	var skill: SkillData = skills_by_id[skill_id]
	for prerequisite in skill.prerequisites:
		if not skills_by_id.has(prerequisite):
			continue
		if _has_dependency_cycle(prerequisite, skills_by_id, visit_states):
			return true

	visit_states[skill_id] = 2
	return false
