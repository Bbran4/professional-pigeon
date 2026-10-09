extends Control
class_name SkillManager

@export var skill_tree: SkillTree
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var zoom: float = 1.0
var panning := false


func _ready() -> void:
	if skill_tree == null:
		skill_tree = get_node_or_null("SkillTree") as SkillTree
	if skill_tree == null:
		push_error("SkillManager requires a SkillTree.")
		return
	_connect_progression_signals()
	_center_on_bread()
	skill_tree._refresh_nodes()


func _connect_progression_signals() -> void:
	if skill_tree == null:
		return
	if not ProgressionManager.points_changed.is_connected(_refresh_tree):
		ProgressionManager.points_changed.connect(_refresh_tree.unbind(1))
	if not ProgressionManager.coin_changed.is_connected(_refresh_tree):
		ProgressionManager.coin_changed.connect(_refresh_tree.unbind(1))
	if not ProgressionManager.skill_level_changed.is_connected(_refresh_tree):
		ProgressionManager.skill_level_changed.connect(_refresh_tree.unbind(2))


func _center_on_bread() -> void:
	if skill_tree == null:
		return
	var bread_node := skill_tree.get_node_or_null("Bread") as Control
	if bread_node == null:
		return
	zoom = 1.0
	skill_tree.scale = Vector2.ONE
	var tree_node_center := bread_node.position + bread_node.size * 0.5
	skill_tree.position = size * 0.5 - tree_node_center


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			panning = mouse_event.pressed
			get_viewport().set_input_as_handled()
			return
		if not mouse_event.pressed:
			return
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_mouse(zoom_step, mouse_event.position)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_mouse(-zoom_step, mouse_event.position)
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if not panning or skill_tree == null:
		return
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		skill_tree.position += motion.relative
		get_viewport().set_input_as_handled()


func _zoom_at_mouse(delta: float, mouse_position: Vector2) -> void:
	if skill_tree == null:
		return
	var old_zoom := zoom
	zoom = clampf(zoom + delta, min_zoom, max_zoom)
	if is_equal_approx(old_zoom, zoom):
		return
	var canvas_position_before := (mouse_position - skill_tree.position) / old_zoom
	skill_tree.scale = Vector2.ONE * zoom
	skill_tree.position = mouse_position - canvas_position_before * zoom


func _refresh_tree() -> void:
	if skill_tree != null:
		skill_tree._refresh_nodes()
		skill_tree.queue_redraw()
