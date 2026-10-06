extends Control
class_name SkillManager

var skill_tree: SkillTree
@onready var skill_canvas: Control = $SkillCanvas
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var pan_speed: float = 1.0

var zoom: float = 1.0
var panning: bool = false


func setup(tree: SkillTree) -> void:
	skill_tree = tree
	_setup_skill_buttons()


func _ready() -> void:
	if skill_canvas == null:
		push_error("SkillManager requires a SkillCanvas.")
		return

	ProgressionManager.food_changed.connect(_refresh_buttons.unbind(1))
	ProgressionManager.coin_changed.connect(_refresh_buttons.unbind(1))
	ProgressionManager.skill_level_changed.connect(_refresh_buttons.unbind(2))

	if skill_tree != null:
		_setup_skill_buttons()


func _setup_skill_buttons() -> void:
	if skill_canvas == null or skill_tree == null:
		return

	for child in skill_canvas.get_children():
		var skill_button := child as SkillButton
		if skill_button == null:
			continue
		skill_button.setup(skill_tree)


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or skill_canvas == null:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			if mouse_event.pressed and not _is_mouse_inside():
				return
			panning = mouse_event.pressed
			get_viewport().set_input_as_handled()
			return

		if mouse_event.pressed and _is_mouse_inside():
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_at_mouse(zoom_step, get_local_mouse_position())
				get_viewport().set_input_as_handled()
				return
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at_mouse(-zoom_step, get_local_mouse_position())
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseMotion and panning:
		var motion := event as InputEventMouseMotion
		skill_canvas.position += motion.relative * pan_speed
		get_viewport().set_input_as_handled()


func _is_mouse_inside() -> bool:
	return Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position())

func _zoom_at_mouse(delta: float, mouse_position: Vector2) -> void:
	var old_zoom := zoom
	zoom = clampf(zoom + delta, min_zoom, max_zoom)

	if is_equal_approx(old_zoom, zoom):
		return

	var canvas_position_before := (mouse_position - skill_canvas.position) / old_zoom
	skill_canvas.scale = Vector2.ONE * zoom
	skill_canvas.position = mouse_position - canvas_position_before * zoom


func _refresh_buttons() -> void:
	if skill_canvas == null:
		return

	for child in skill_canvas.get_children():
		var skill_button := child as SkillButton
		if skill_button:
			skill_button.refresh()
