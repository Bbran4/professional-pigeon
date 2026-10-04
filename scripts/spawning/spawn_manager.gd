extends Node2D
class_name SpawnManager

@export var bread_scene: PackedScene
@export var bread_count: int = 2

## Bread can only spawn at these predefined ground positions.
## Each run randomly selects from this list.
@export var bread_spawn_points: Array[Vector2] = [
	Vector2(460, 559),
	Vector2(540, 559),
	Vector2(620, 559),
	Vector2(1260, 559),
	Vector2(1330, 559),
	Vector2(1380, 559)
]


func _ready() -> void:
	spawn_bread()


func spawn_bread() -> void:
	if bread_scene == null:
		push_error("SpawnManager requires a Bread scene.")
		return

	var spawn_points := get_random_spawn_points()

	for spawn_position in spawn_points:
		var bread := bread_scene.instantiate() as Node2D

		if bread == null:
			continue

		bread.position = spawn_position
		add_child(bread)


func get_random_spawn_points() -> Array[Vector2]:
	var selected_points: Array[Vector2] = []

	if bread_count <= 0 or bread_spawn_points.is_empty():
		return selected_points

	var available_points := bread_spawn_points.duplicate()
	available_points.shuffle()

	var amount_to_spawn := mini(bread_count, available_points.size())

	for index in range(amount_to_spawn):
		selected_points.append(available_points[index])

	return selected_points
