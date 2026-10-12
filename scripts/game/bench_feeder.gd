extends Node2D
class_name BenchFeeder

const FEEDER_SKILL: StringName = EffectIds.BENCH_FEEDER

@onready var seed_feeder: SeedFeeder = $SeedFeeder


func _ready() -> void:
	if not ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_refresh_unlock_state()


func _on_skill_level_changed(skill_id: StringName, _new_level: int) -> void:
	if skill_id == FEEDER_SKILL:
		_refresh_unlock_state()


func _refresh_unlock_state() -> void:
	# The feeder upgrade unlocks bench feeders without removing the starter feeder.
	var unlocked := ProgressionManager.get_effect_value(FEEDER_SKILL) > 0.0
	visible = unlocked
	if is_instance_valid(seed_feeder):
		seed_feeder.visible = unlocked
		seed_feeder.set_gameplay_enabled(unlocked)
