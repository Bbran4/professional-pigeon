extends Node2D

## Development-only movement and combat test arena.
## The visuals are intentionally simple for now so the arena can be used
## to test movement, collision, spacing, and future combat interactions.

const ARENA_SIZE := Vector2(2400.0, 1600.0)
const HALF_SIZE := ARENA_SIZE / 2.0
const GRID_SPACING := 100.0
const BORDER_WIDTH := 32.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Ground
	draw_rect(Rect2(-HALF_SIZE, ARENA_SIZE), Color("#20252b"))

	# Subtle floor grid
	for x in range(int(-HALF_SIZE.x), int(HALF_SIZE.x) + 1, int(GRID_SPACING)):
		draw_line(Vector2(x, -HALF_SIZE.y), Vector2(x, HALF_SIZE.y), Color("#2b323a"), 2.0)

	for y in range(int(-HALF_SIZE.y), int(HALF_SIZE.y) + 1, int(GRID_SPACING)):
		draw_line(Vector2(-HALF_SIZE.x, y), Vector2(HALF_SIZE.x, y), Color("#2b323a"), 2.0)

	# Arena border
	draw_rect(Rect2(-HALF_SIZE, ARENA_SIZE), Color("#59636e"), false, BORDER_WIDTH)

	# Center crosshair makes movement direction and spacing easier to read.
	draw_line(Vector2(-80, 0), Vector2(80, 0), Color("#414b55"), 3.0)
	draw_line(Vector2(0, -80), Vector2(0, 80), Color("#414b55"), 3.0)

	# Simple obstacle visuals.
	for obstacle in [
		Rect2(-650, -350, 220, 140),
		Rect2(430, -260, 180, 240),
		Rect2(-160, 300, 320, 120)
	]:
		draw_rect(obstacle, Color("#39434d"))
		draw_rect(obstacle, Color("#687581"), false, 6.0)

func _process(_delta: float) -> void:
	queue_redraw()
