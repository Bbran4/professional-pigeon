extends Resource
class_name SkillCatalog

## Collection of static skill definitions shared by the progression system.

@export var skills: Array[SkillData] = []


## Validate the catalog and report every structural issue.
## Returns true when all skill IDs, prerequisites, and tree positions are valid.
func validate() -> bool:
	var valid := true
	var skills_by_id: Dictionary = {}
	var skill_rects: Array[Dictionary] = []

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

		var skill_rect := Rect2(skill.tree_position, Vector2(190.0, 100.0))
		for entry in skill_rects:
			var other_rect: Rect2 = entry.rect
			if skill_rect.intersects(other_rect):
				var other: SkillData = entry.skill
				push_error(
					"SkillCatalog: skills '%s' and '%s' overlap (%s intersects %s)."
					% [other.id, skill.id, other_rect, skill_rect]
				)
				valid = false
		skill_rects.append({"skill": skill, "rect": skill_rect})

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
