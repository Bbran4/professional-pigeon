extends Node2D
class_name SpawnManager

@export var bread_scene: PackedScene
@export var bread_spawn_positions: Array[Vector2] = [
	Vector2(500, 350),
	Vector2(850, 300)
]


func _ready() -> void:
	spawn_bread()


func spawn_bread() -> void:
	if bread_scene == null:
		push_error("SpawnManager requires a Bread scene.")
		return

	for spawn_position in bread_spawn_positions:
		var bread := bread_scene.instantiate() as Node2D

		if bread == null:
			continue

		bread.position = spawn_position
		add_child(bread)
