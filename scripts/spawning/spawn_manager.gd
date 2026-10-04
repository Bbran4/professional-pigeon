extends Node2D
class_name SpawnManager

@export var bread_scene: PackedScene
@export var bread_count: int = 2
@export var ground_y: float = 568.0
@export var bread_half_height: float = 9.0
@export var ground_spawn_regions: Array[Rect2] = [
	Rect2(420, 528, 230, 40),
	Rect2(1210, 528, 190, 40)
]
@export var minimum_bread_distance: float = 64.0


func _ready() -> void:
	spawn_bread()


func spawn_bread() -> void:
	if bread_scene == null:
		push_error("SpawnManager requires a Bread scene.")
		return

	var spawn_positions := get_random_ground_positions()

	for spawn_position in spawn_positions:
		var bread := bread_scene.instantiate() as Node2D

		if bread == null:
			continue

		bread.position = spawn_position
		add_child(bread)


func get_random_ground_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []

	if bread_count <= 0 or ground_spawn_regions.is_empty():
		return positions

	var random := RandomNumberGenerator.new()
	random.randomize()

	var max_attempts : int = max(bread_count * 20, 20)

	for _attempt in range(max_attempts):
		if positions.size() >= bread_count:
			break

		var region := ground_spawn_regions[random.randi_range(0, ground_spawn_regions.size() - 1)]

		var x := random.randf_range(region.position.x, region.end.x)
		var y := ground_y - bread_half_height
		var candidate := Vector2(x, y)

		if is_spawn_position_valid(candidate, positions):
			positions.append(candidate)

	return positions


func is_spawn_position_valid(candidate: Vector2, existing_positions: Array[Vector2]) -> bool:
	for existing_position in existing_positions:
		if candidate.distance_to(existing_position) < minimum_bread_distance:
			return false

	return true
