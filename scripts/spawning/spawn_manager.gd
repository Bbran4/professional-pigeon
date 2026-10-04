extends Node2D
class_name SpawnManager

@export var bread_scene: PackedScene
@export var bread_count: int = 2
@export var ground_y: float = 568.0
@export var world_start: float = 24.0
@export var world_end: float = 5976.0
@export var minimum_spawn_spacing: float = 100.0


func _ready() -> void:
	spawn_bread()


func spawn_bread() -> void:
	if bread_scene == null:
		push_error("SpawnManager requires a Bread scene.")
		return

	var amount_to_spawn := bread_count + get_additional_bread_spawns()
	var spawn_positions := get_random_spawn_positions(amount_to_spawn)

	for spawn_position in spawn_positions:
		var bread := bread_scene.instantiate() as Node2D
		if bread == null:
			continue
		bread.position = spawn_position
		add_child(bread)


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


func get_additional_bread_spawns() -> int:
	return ProgressionManager.get_skill_level(&"bread_spawns")
