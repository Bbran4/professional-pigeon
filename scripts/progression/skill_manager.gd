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
	_center_on_starting_skill()
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


func _center_on_starting_skill() -> void:
	if skill_tree == null:
		return
	var starting_node := skill_tree.nodes_by_id.get(&"bread") as Control
	if starting_node == null:
		return
	zoom = 1.0
	skill_tree.scale = Vector2.ONE
	var tree_node_center := starting_node.position + starting_node.size * 0.5
	skill_tree.position = size * 0.5 - tree_node_center
	_clamp_tree_position()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or skill_tree == null:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				panning = not _is_over_skill_node(mouse_event.position)
			else:
				panning = false
			if panning or not mouse_event.pressed:
				get_viewport().set_input_as_handled()
			return
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_mouse(zoom_step, mouse_event.position)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_mouse(-zoom_step, mouse_event.position)
			get_viewport().set_input_as_handled()
		return
	if panning and event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		skill_tree.position += motion.relative
		_clamp_tree_position()
		get_viewport().set_input_as_handled()


func _is_over_skill_node(viewport_position: Vector2) -> bool:
	var manager_position := get_global_transform_with_canvas().affine_inverse() * viewport_position
	var tree_position := (manager_position - skill_tree.position) / zoom
	for child in skill_tree.get_children():
		var skill_node := child as Control
		if skill_node != null and Rect2(skill_node.position, skill_node.size).has_point(tree_position):
			return true
	return false


func _zoom_at_mouse(delta: float, viewport_position: Vector2) -> void:
	if skill_tree == null:
		return
	var mouse_position := get_global_transform_with_canvas().affine_inverse() * viewport_position
	var old_zoom := zoom
	zoom = clampf(zoom + delta, min_zoom, max_zoom)
	if is_equal_approx(old_zoom, zoom):
		return
	var canvas_position_before := (mouse_position - skill_tree.position) / old_zoom
	skill_tree.scale = Vector2.ONE * zoom
	skill_tree.position = mouse_position - canvas_position_before * zoom
	_clamp_tree_position()


func _clamp_tree_position() -> void:
	if skill_tree == null:
		return
	var scaled_size := skill_tree.size * zoom
	var min_position := size - scaled_size
	skill_tree.position = Vector2(
		clampf(skill_tree.position.x, min_position.x, 0.0),
		clampf(skill_tree.position.y, min_position.y, 0.0)
	)


func _refresh_tree() -> void:
	if skill_tree != null:
		skill_tree._refresh_nodes()
		skill_tree.queue_redraw()
