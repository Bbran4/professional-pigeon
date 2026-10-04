extends Control
class_name SkillManager

var skill_tree: SkillTree
@export var skill_canvas: Control
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var pan_speed: float = 1.0

var zoom: float = 1.0
var panning: bool = false
var last_mouse_position: Vector2


func setup(tree: SkillTree) -> void:
	skill_tree = tree
	_setup_skill_buttons()


func _ready() -> void:
	if skill_canvas == null:
		push_error("SkillManager requires a SkillCanvas.")
		return

	ProgressionManager.food_changed.connect(_on_progression_changed)
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)

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
	if not visible or skill_canvas == null:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_MIDDLE:
			panning = mouse_event.pressed
			last_mouse_position = mouse_event.position
			get_viewport().set_input_as_handled()
			return

		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_mouse(zoom_step, mouse_event.position)
			get_viewport().set_input_as_handled()
			return

		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_mouse(-zoom_step, mouse_event.position)
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseMotion and panning:
		var motion := event as InputEventMouseMotion
		skill_canvas.position += motion.relative * pan_speed
		get_viewport().set_input_as_handled()


func _zoom_at_mouse(delta: float, mouse_position: Vector2) -> void:
	var old_zoom := zoom
	zoom = clampf(zoom + delta, min_zoom, max_zoom)

	if is_equal_approx(old_zoom, zoom):
		return

	var canvas_position_before := (mouse_position - skill_canvas.position) / old_zoom
	skill_canvas.scale = Vector2.ONE * zoom
	skill_canvas.position = mouse_position - canvas_position_before * zoom


func _on_progression_changed(_food: int) -> void:
	_refresh_buttons()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	_refresh_buttons()


func _refresh_buttons() -> void:
	if skill_canvas == null:
		return

	for child in skill_canvas.get_children():
		var skill_button := child as SkillButton
		if skill_button:
			skill_button.refresh()
