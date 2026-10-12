extends Node
class_name Unlockable

## Attach as a child of the Node2D that should become visible when a skill is
## unlocked. Uses the skill's actual level rather than its effect total.

@export var required_skill: StringName = &""
@export_range(1, 100, 1) var min_level: int = 1

var _target: Node2D


func _ready() -> void:
	_target = get_parent() as Node2D
	if _target == null:
		push_error("Unlockable: parent must be a Node2D.")
		return
	if required_skill == &"":
		push_error("Unlockable: required_skill must be configured.")
		return
	if not ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_refresh_visibility()


func _on_skill_level_changed(skill_id: StringName, _new_level: int) -> void:
	if skill_id == required_skill:
		_refresh_visibility()


func _refresh_visibility() -> void:
	if is_instance_valid(_target):
		_target.visible = ProgressionManager.get_skill_level(required_skill) >= min_level
