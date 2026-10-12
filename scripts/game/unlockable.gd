extends Node
class_name Unlockable

## Attach as a child of the Node2D that should become visible when its
## configured skill requirements are satisfied.

@export var required_skills: Array[StringName] = []
@export var require_all_skills: bool = true
@export_range(1, 100, 1) var min_level: int = 1

var _target: Node2D


func _ready() -> void:
	_target = get_parent() as Node2D
	if _target == null:
		push_error("Unlockable: parent must be a Node2D.")
		return
	if required_skills.is_empty():
		push_error("Unlockable: add at least one skill to required_skills in the Inspector.")
		return
	if not ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_refresh_visibility()


func _on_skill_level_changed(skill_id: StringName, _new_level: int) -> void:
	if required_skills.has(skill_id):
		_refresh_visibility()


func _refresh_visibility() -> void:
	if not is_instance_valid(_target):
		return

	var requirements_met := require_all_skills
	for skill_id in required_skills:
		var skill_met := ProgressionManager.get_skill_level(skill_id) >= min_level
		if require_all_skills and not skill_met:
			requirements_met = false
			break
		if not require_all_skills and skill_met:
			requirements_met = true
			break
	_target.visible = requirements_met
