extends Resource
class_name SkillCatalog

## Collection of static skill definitions shared by the progression system.

@export var skills: Array[SkillData] = []


## Validate the catalog and report every structural issue.
## Returns true when all skill IDs, prerequisites, and tree positions are valid.
func validate() -> bool:
	var valid := true
	var skills_by_id: Dictionary = {}
	var skills_by_position: Dictionary = {}

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

		if skills_by_position.has(skill.tree_position):
			var other: SkillData = skills_by_position[skill.tree_position]
			push_error(
				"SkillCatalog: skills '%s' and '%s' overlap at %s."
				% [other.id, skill.id, skill.tree_position]
			)
			valid = false
		else:
			skills_by_position[skill.tree_position] = skill

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

	return valid
