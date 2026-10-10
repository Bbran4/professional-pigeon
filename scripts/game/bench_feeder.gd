extends Node2D
class_name BenchFeeder

const FEEDER_SKILL: StringName = &"bench_feeder"

@onready var seed_feeder: SeedFeeder = $SeedFeeder


func _ready() -> void:
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_refresh_unlock_state()


func _on_skill_level_changed(skill_id: StringName, _new_level: int) -> void:
	if skill_id == FEEDER_SKILL:
		_refresh_unlock_state()


func _refresh_unlock_state() -> void:
	var unlocked := ProgressionManager.get_skill_level(FEEDER_SKILL) > 0
	visible = unlocked
	if is_instance_valid(seed_feeder):
		seed_feeder.visible = unlocked
