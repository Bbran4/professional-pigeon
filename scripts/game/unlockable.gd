extends Node
class_name Unlockable

## Attach as a child of the Node2D that should become visible when its
## configured skill requirements are satisfied.

@export var required_skills: Array[StringName] = []
@export var require_all_skills: bool = true
@export_range(1, 100, 1) var min_level: int = 1

var _target: Node2D
var _valid_required_skills: Array[StringName] = []


func _ready() -> void:
	_target = get_parent() as Node2D
	if _target == null:
		push_error("Unlockable '%s': parent must be a Node2D. Attach this script under the object it controls." % get_path())
		return
	if required_skills.is_empty():
		push_error("Unlockable '%s': required_skills is empty. Add at least one existing skill ID in the Inspector." % get_path())
		_target.visible = false
		return

	for skill_id in required_skills:
		if skill_id == &"":
			push_error("Unlockable '%s': required_skills contains an empty ID. Replace it with a valid SkillData ID." % get_path())
			continue
		if SkillPurchases.get_skill(skill_id) == null:
			push_error("Unlockable '%s': unknown skill ID '%s'. Check data/skills/skill_catalog.tres and correct required_skills." % [get_path(), skill_id])
			continue
		if not _valid_required_skills.has(skill_id):
			_valid_required_skills.append(skill_id)

	if _valid_required_skills.is_empty():
		push_error("Unlockable '%s': none of its requirements match a skill in the catalog. The target will remain hidden." % get_path())
		_target.visible = false
		return

	if not ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_refresh_visibility()


func _on_skill_level_changed(skill_id: StringName, _new_level: int) -> void:
	if _valid_required_skills.has(skill_id):
		_refresh_visibility()


func _refresh_visibility() -> void:
	if not is_instance_valid(_target):
		return

	if require_all_skills:
		for skill_id in _valid_required_skills:
			if ProgressionManager.get_skill_level(skill_id) < min_level:
				_target.visible = false
				return
		_target.visible = true
		return

	for skill_id in _valid_required_skills:
		if ProgressionManager.get_skill_level(skill_id) >= min_level:
			_target.visible = true
			return
	_target.visible = false
