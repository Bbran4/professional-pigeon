extends Node2D
class_name HumanFeeder

signal bread_thrown(bread: Node2D)
signal feeding_finished

@export var bread_scene: PackedScene
@export var carry_capacity: int = 1
@export var first_throw_delay: float = 0.75
@export var min_throw_interval: float = 1.0
@export var max_throw_interval: float = 2.25
@export var throw_x_min: float = 390.0
@export var throw_x_max: float = 920.0
@export var ground_y: float = 335.0

var active := false
var bread_remaining := 0
var throw_timer := 0.0
var active_bread: Array[Node2D] = []

func start_day() -> void:
	active = true
	bread_remaining = carry_capacity
	throw_timer = first_throw_delay

func end_day() -> void:
	active = false
	bread_remaining = 0
	throw_timer = 0.0
	for bread in active_bread:
		if is_instance_valid(bread):
			bread.hide()
	active_bread.clear()

func _process(delta: float) -> void:
	if not active or bread_remaining <= 0:
		return

	throw_timer -= delta
	if throw_timer > 0.0:
		return

	_throw_bread()

	if bread_remaining > 0:
		throw_timer = randf_range(min_throw_interval, max_throw_interval)
	else:
		feeding_finished.emit()

func _throw_bread() -> void:
	if bread_scene == null:
		return

	var bread := bread_scene.instantiate() as Node2D
	if bread == null:
		return

	get_parent().add_child(bread)
	active_bread.append(bread)
	bread.tree_exited.connect(_on_bread_exited.bind(bread))
	bread.global_position = Vector2(randf_range(throw_x_min, throw_x_max), ground_y)
	bread.show()
	bread_remaining -= 1
	bread_thrown.emit(bread)


func _on_bread_exited(bread: Node2D) -> void:
	active_bread.erase(bread)
