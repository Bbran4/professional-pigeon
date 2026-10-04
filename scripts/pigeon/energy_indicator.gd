extends Node2D
class_name EnergyIndicator

@export var radius: float = 13.0
@export var line_width: float = 4.0
@export var offset: Vector2 = Vector2(0.0, -28.0)

const BACKGROUND_COLOR := Color(0.08, 0.11, 0.16, 0.8)
const ENERGY_COLOR := Color(0.2, 0.65, 1.0, 1.0)
const LOW_ENERGY_COLOR := Color(1.0, 0.15, 0.12, 1.0)

var energy_ratio: float = 1.0
var energy_color: Color = ENERGY_COLOR
var red_tween: Tween


func _ready() -> void:
	position = offset
	visible = false
	queue_redraw()


func _process(_delta: float) -> void:
	var pigeon := get_parent() as Pigeon
	if pigeon == null or pigeon.stats == null:
		return

	energy_ratio = clampf(pigeon.current_energy / pigeon.stats.max_energy, 0.0, 1.0)

	if energy_ratio <= 0.1 and red_tween == null and energy_color != LOW_ENERGY_COLOR:
		red_tween = create_tween()
		red_tween.tween_property(self, "energy_color", LOW_ENERGY_COLOR, 1.0)
		red_tween.finished.connect(_on_red_tween_finished)

	queue_redraw()


func reset_color() -> void:
	if red_tween:
		red_tween.kill()
		red_tween = null

	energy_color = ENERGY_COLOR
	queue_redraw()


func _on_red_tween_finished() -> void:
	red_tween = null


func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, BACKGROUND_COLOR, line_width, true)

	if energy_ratio <= 0.0:
		return

	var start_angle := -PI / 2.0
	var end_angle := start_angle + TAU * energy_ratio

	draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 48, energy_color, line_width, true)
