extends Node2D
class_name EnergyIndicator

@export var dot_radius: float = 4.0
@export var dot_spacing: float = 11.0
@export var offset: Vector2 = Vector2(0.0, -28.0)

const DOTS_PER_ROW := 5
const ROW_SPACING := 11.0

const BACKGROUND_COLOR := Color(0.08, 0.11, 0.16, 0.8)
const ENERGY_COLOR := Color(0.2, 0.65, 1.0, 1.0)
var energy_ratio: float = 1.0
var max_energy: int = 1


func _ready() -> void:
	position = offset
	visible = false
	queue_redraw()


func _process(_delta: float) -> void:
	var pigeon := get_parent() as Pigeon
	if pigeon == null or pigeon.stats == null:
		return

	max_energy = maxi(1, int(ceilf(pigeon.get_max_energy())))
	energy_ratio = clampf(pigeon.current_energy / pigeon.get_max_energy(), 0.0, 1.0)

	visible = energy_ratio < 1.0
	queue_redraw()


func _draw() -> void:
	var current_energy := energy_ratio * float(max_energy)
	var row_count := int(ceil(float(max_energy) / float(DOTS_PER_ROW)))

	for i in range(max_energy):
		var row := i / DOTS_PER_ROW
		var column := i % DOTS_PER_ROW
		var dots_in_row := mini(DOTS_PER_ROW, max_energy - row * DOTS_PER_ROW)
		var x := (float(column) - float(dots_in_row - 1) * 0.5) * dot_spacing
		var y := (float(row) - float(row_count - 1) * 0.5) * ROW_SPACING
		var dot_position := Vector2(x, y)

		if float(i) < current_energy:
			draw_circle(dot_position, dot_radius, ENERGY_COLOR)
		else:
			draw_circle(dot_position, dot_radius, BACKGROUND_COLOR)
