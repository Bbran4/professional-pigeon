extends Control
class_name CooldownIndicator

@export var label_text: String = "S"
@export var radius: float = 16.0
@export var stroke_width: float = 4.0

var progress: float = 1.0
var active: bool = false
var cooldown_seconds: float = 0.0


func set_progress(value: float, is_active: bool, remaining: float) -> void:
	var new_progress := clampf(value, 0.0, 1.0)
	var new_seconds := maxf(remaining, 0.0)

	if is_equal_approx(new_progress, progress) \
			and is_active == active \
			and is_equal_approx(new_seconds, cooldown_seconds):
		return

	progress = new_progress
	active = is_active
	cooldown_seconds = new_seconds
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var background_radius := minf(radius, minf(size.x, size.y) * 0.5 - stroke_width)
	var start_angle := -PI * 0.5

	draw_arc(center, background_radius, 0.0, TAU, 40, Color(0.12, 0.15, 0.2, 0.9), stroke_width, true)

	if progress > 0.0:
		draw_arc(
			center,
			background_radius,
			start_angle,
			start_angle + TAU * progress,
			40,
			Color(0.9, 0.75, 0.32, 1.0) if active else Color(0.55, 0.78, 0.95, 1.0),
			stroke_width,
			true
		)

	var font := ThemeDB.fallback_font
	var font_size := 10
	var text := label_text
	if active:
		text = "%.1f" % cooldown_seconds
	elif progress < 1.0:
		text = "%.1f" % cooldown_seconds

	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(
		font,
		center - Vector2(text_size.x * 0.5, -font_size * 0.35),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		Color(0.92, 0.94, 0.98, 1.0)
	)
