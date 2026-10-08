extends Node2D
class_name BreadThrower

signal bread_landed(bread: ThrownBread)
signal stock_changed(current: int, capacity: int)

@export var bread_scene: PackedScene
@export var stock_capacity: int = 5
@export var throw_origin: Vector2 = Vector2(70.0, 330.0)
@export var park_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)
@export var max_throw_distance: float = 850.0
@export var flight_time: float = 0.55
@export var arc_height: float = 90.0

var bread_remaining: int = 0
var aim_position: Vector2
var active := false
var _active_bread: Array[ThrownBread] = []


func _ready() -> void:
	aim_position = _clamp_to_park(get_global_mouse_position())
	set_process(false)
	queue_redraw()


func start_day() -> void:
	active = true
	bread_remaining = _get_stock_capacity()
	aim_position = _clamp_to_park(get_global_mouse_position())
	stock_changed.emit(bread_remaining, _get_stock_capacity())
	set_process(true)
	queue_redraw()


func end_day() -> void:
	active = false
	bread_remaining = 0
	for bread in _active_bread:
		if is_instance_valid(bread):
			bread.queue_free()
	_active_bread.clear()
	stock_changed.emit(bread_remaining, _get_stock_capacity())
	set_process(false)
	queue_redraw()


func _process(_delta: float) -> void:
	if not active:
		return

	aim_position = _clamp_to_park(get_global_mouse_position())
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not active or bread_remaining <= 0:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_throw_at(aim_position)
			get_viewport().set_input_as_handled()


func _throw_at(target: Vector2) -> void:
	if bread_scene == null:
		return

	if throw_origin.distance_to(target) > max_throw_distance:
		return

	var bread := bread_scene.instantiate() as ThrownBread
	if bread == null:
		return

	get_parent().add_child(bread)
	bread.global_position = throw_origin
	bread.flight_time = flight_time
	bread.arc_height = arc_height
	bread.launch(throw_origin, target)
	bread.landed.connect(_on_bread_landed)
	bread.tree_exited.connect(_on_bread_exited.bind(bread))

	_active_bread.append(bread)
	bread_remaining -= 1
	stock_changed.emit(bread_remaining, _get_stock_capacity())
	queue_redraw()


func _on_bread_landed(bread: ThrownBread) -> void:
	if not active:
		return
	bread_landed.emit(bread)


func _on_bread_exited(bread: ThrownBread) -> void:
	_active_bread.erase(bread)


func get_stock_capacity() -> int:
	if ProgressionManager.get_skill_level(&"bread") <= 0:
		return 0
	return stock_capacity


func _clamp_to_park(position: Vector2) -> Vector2:
	var clamped := position.clamp(
		park_bounds.position,
		park_bounds.position + park_bounds.size
	)
	var origin_to_target := clamped - throw_origin
	if origin_to_target.length() > max_throw_distance:
		clamped = throw_origin + origin_to_target.normalized() * max_throw_distance
	return clamped


func _draw() -> void:
	var origin := throw_origin
	var target := aim_position
	var can_throw := active and bread_remaining > 0 and origin.distance_to(target) <= max_throw_distance

	# Temporary hand placeholder. Replace with hand art later.
	draw_circle(origin + Vector2(0.0, 8.0), 22.0, Color(0.82, 0.66, 0.52, 1.0))
	draw_circle(origin + Vector2(0.0, -12.0), 15.0, Color(0.82, 0.66, 0.52, 1.0))
	draw_rect(Rect2(origin + Vector2(-18.0, 20.0), Vector2(36.0, 28.0)), Color(0.15, 0.12, 0.1, 1.0))

	if not active:
		return

	var arc_color := Color(1.0, 1.0, 1.0, 0.75) if can_throw else Color(0.9, 0.3, 0.3, 0.75)
	for i in range(21):
		var t := float(i) / 20.0
		var point := origin.lerp(target, t)
		point.y -= arc_height * 4.0 * t * (1.0 - t)
		draw_circle(point, 2.5, arc_color)

	var marker_color := Color(1.0, 1.0, 1.0, 0.9) if can_throw else Color(0.9, 0.3, 0.3, 0.9)
	draw_arc(target, 18.0, 0.0, TAU, 32, marker_color, 3.0)
	draw_arc(target, 8.0, 0.0, TAU, 24, marker_color, 2.0)
