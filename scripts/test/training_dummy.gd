extends StaticBody2D
class_name TrainingDummy

## Development-only combat target.
## It never dies, but records incoming damage for future combat feedback.

@onready var health: Health = $Health

var last_damage: float = 0.0
var hit_flash_time: float = 0.0

func _ready() -> void:
	health.damage_taken.connect(_on_damage_taken)
	queue_redraw()

func _on_damage_taken(amount: float) -> void:
	last_damage = amount
	hit_flash_time = 0.12
	queue_redraw()

func _process(delta: float) -> void:
	if hit_flash_time > 0.0:
		hit_flash_time = max(hit_flash_time - delta, 0.0)
		queue_redraw()

func _draw() -> void:
	var body_color := Color("#d8a36d") if hit_flash_time > 0.0 else Color("#9b6b45")
	var dark_color := Color("#6b472f")

	draw_circle(Vector2(0, -34), 22.0, body_color)
	draw_rect(Rect2(-10, -15, 20, 58), body_color)
	draw_rect(Rect2(-38, -4, 76, 12), dark_color)
	draw_line(Vector2(-24, 58), Vector2(0, 40), dark_color, 10.0)
	draw_line(Vector2(24, 58), Vector2(0, 40), dark_color, 10.0)

	draw_circle(Vector2(-7, -37), 3.0, Color("#20252b"))
	draw_circle(Vector2(7, -37), 3.0, Color("#20252b"))

	# Visualise the future attackable area.
	draw_arc(Vector2(0, 8), 42.0, 0.0, TAU, 32, Color("#d7dce1"), 2.0)

func show_damage(amount: float) -> void:
	_on_damage_taken(amount)
