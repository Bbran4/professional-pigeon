extends RefCounted
class_name CollectibleDropService

## Owns feather instantiation and all skill-driven drop/reward modifiers.

const BALANCE: GameBalance = preload("res://data/game_balance.tres")
const FEATHER_SCENE: PackedScene = preload("res://scenes/park/feather.tscn")

var park_node: Node


func configure(park: Node) -> void:
	park_node = park


func spawn_visit_feathers(drop_position: Vector2, point_reward: int) -> void:
	spawn_feather(drop_position, point_reward)
	for _index in range(int(ProgressionManager.get_effect_value(EffectIds.FEATHER_COUNT_ADD))):
		var offset := Vector2(
			randf_range(-BALANCE.extra_feather_offset_x, BALANCE.extra_feather_offset_x),
			randf_range(-BALANCE.extra_feather_offset_y, BALANCE.extra_feather_offset_y)
		)
		# Every feather is an individual collectible and grants the visit's reward.
		spawn_feather(drop_position + offset, point_reward)


func spawn_feather(spawn_position: Vector2, point_reward: int = 0) -> void:
	if not is_instance_valid(park_node):
		push_error("CollectibleDropService: park node is no longer available.")
		return
	var feather := FEATHER_SCENE.instantiate() as Feather
	if feather == null:
		push_error("CollectibleDropService: feather scene root must be a Feather.")
		return
	park_node.add_child(feather)
	feather.global_position = spawn_position
	DomainEvents.collectible_spawned.emit(feather)
	feather.z_index = 20
	feather.z_as_relative = false
	feather.point_value = point_reward
	feather.point_value += int(ProgressionManager.get_effect_value(EffectIds.FEATHER_VALUE_ADD))
	var is_golden := randf() < ProgressionManager.get_effect_value(EffectIds.GOLDEN_FEATHER_CHANCE)
	feather.set_golden(is_golden)
	if is_golden:
		feather.point_value += BALANCE.golden_feather_bonus_points
