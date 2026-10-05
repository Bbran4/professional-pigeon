extends Node2D
class_name SpawnManager

@export var collectible_scenes: Array[PackedScene] = []
@export var collectible_resources: Array[ResourceData] = []
@export var collectible_count: int = 20
@export var ground_y: float = 568.0
@export var world_start: float = 24.0
@export var world_end: float = 5976.0
@export var minimum_spawn_spacing: float = 100.0


func _ready() -> void:
	randomize()
	spawn_collectibles()


func spawn_collectibles() -> void:
	if collectible_scenes.is_empty() or collectible_resources.is_empty():
		push_error("SpawnManager requires collectible scenes and resources.")
		return

	var count := collectible_count + get_additional_food_spawns()
	var spawn_positions := get_random_spawn_positions(count)

	for spawn_position in spawn_positions:
		var scene_index := choose_resource_index()
		if scene_index < 0 or scene_index >= collectible_scenes.size():
			continue

		var collectible := collectible_scenes[scene_index].instantiate() as Collectible
		if collectible == null:
			continue

		collectible.resource = collectible_resources[scene_index]
		collectible.position = spawn_position
		add_child(collectible)


func choose_resource_index() -> int:
	var total_weight := 0.0
	for resource in collectible_resources:
		if resource:
			total_weight += maxf(resource.spawn_weight, 0.0)

	if total_weight <= 0.0:
		return -1

	var roll := randf_range(0.0, total_weight)
	var accumulated := 0.0

	for i in range(collectible_resources.size()):
		var resource := collectible_resources[i]
		if resource == null:
			continue
		accumulated += maxf(resource.spawn_weight, 0.0)
		if roll <= accumulated:
			return i

	return collectible_resources.size() - 1


func get_random_spawn_positions(amount: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if amount <= 0 or world_end <= world_start:
		return positions

	var attempts := 0
	var max_attempts := amount * 30

	while positions.size() < amount and attempts < max_attempts:
		attempts += 1
		var candidate := randf_range(world_start, world_end)
		var is_too_close := false

		for existing in positions:
			if absf(existing.x - candidate) < minimum_spawn_spacing:
				is_too_close = true
				break

		if not is_too_close:
			positions.append(Vector2(candidate, ground_y))

	return positions


func get_additional_food_spawns() -> int:
	return ProgressionManager.get_skill_level(&"bread_spawns")
