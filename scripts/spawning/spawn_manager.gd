extends Node2D
class_name SpawnManager

@export var collectible_scenes: Array[PackedScene] = []
@export var collectible_resources: Array[ResourceData] = []
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

	var spawn_requests: Array[Dictionary] = []

	for i in range(mini(collectible_scenes.size(), collectible_resources.size())):
		var resource := collectible_resources[i]
		if resource == null or not is_resource_unlocked(resource):
			continue

		if randf_range(0.0, 100.0) > resource.spawn_chance:
			continue

		var amount := get_spawn_amount(resource)
		if amount <= 0:
			continue

		spawn_requests.append({
			"scene_index": i,
			"amount": amount
		})

	var total_amount := 0
	for request in spawn_requests:
		total_amount += int(request.amount)

	var spawn_positions := get_random_spawn_positions(total_amount)
	var position_index := 0

	for request in spawn_requests:
		var scene_index := int(request.scene_index)
		var amount := int(request.amount)

		for _i in range(amount):
			if position_index >= spawn_positions.size():
				return

			var collectible := collectible_scenes[scene_index].instantiate() as Collectible
			if collectible == null:
				continue

			collectible.resource = collectible_resources[scene_index]
			collectible.position = spawn_positions[position_index]
			add_child(collectible)
			position_index += 1


func is_resource_unlocked(resource: ResourceData) -> bool:
	if resource.unlock_skill_id == &"":
		return true

	return ProgressionManager.get_skill_level(resource.unlock_skill_id) > 0


func get_spawn_amount(resource: ResourceData) -> int:
	var amount := resource.base_spawn_amount

	if resource.spawn_upgrade_id != &"":
		amount += int(ProgressionManager.get_skill_level(resource.spawn_upgrade_id))

	return maxi(amount, 0)


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
