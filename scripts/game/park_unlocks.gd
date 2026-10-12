extends Node
class_name ParkUnlocks

## Controls visibility of park scenery authored in game.tscn.
## This node never creates or frees scenery instances.

@export var upgrade_bench_groups: Array[Node2D] = []
@export var fountain: Node2D
@export var tree_nests: Node2D


func _ready() -> void:
	if not ProgressionManager.skill_level_changed.is_connected(_on_skill_level_changed):
		ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_refresh_visibility()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	_refresh_visibility()


func _refresh_visibility() -> void:
	var bench_count := clampi(
		int(ProgressionManager.get_effect_value(EffectIds.BENCH_COUNT_ADD)),
		0,
		upgrade_bench_groups.size()
	)
	for index in range(upgrade_bench_groups.size()):
		var bench_group := upgrade_bench_groups[index]
		if is_instance_valid(bench_group):
			bench_group.visible = index < bench_count

	if is_instance_valid(fountain):
		fountain.visible = ProgressionManager.get_effect_value(EffectIds.FOUNTAIN_UNLOCK) > 0.0

	if is_instance_valid(tree_nests):
		tree_nests.visible = ProgressionManager.get_effect_value(EffectIds.TREE_NESTS) > 0.0
