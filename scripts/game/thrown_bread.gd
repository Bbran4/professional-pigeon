extends Node2D
class_name ThrownBread

signal landed(bread: ThrownBread)

@export var flight_time: float = 0.55
@export var arc_height: float = 90.0

@onready var visual: Node2D = $Visual
@onready var shadow: Node2D = $Shadow

var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var _t := 0.0
var _flying := false


func _ready() -> void:
	visual.position = Vector2.ZERO
	shadow.position = Vector2.ZERO


func launch(from: Vector2, to: Vector2) -> void:
	start_position = from
	target_position = to
	global_position = from
	_t = 0.0
	_flying = true
	visual.position = Vector2.ZERO
	shadow.position = Vector2.ZERO
	set_process(true)


func _process(delta: float) -> void:
	if not _flying:
		return

	_t = minf(_t + delta / maxf(flight_time, 0.01), 1.0)
	global_position = start_position.lerp(target_position, _t)

	var arc := 4.0 * _t * (1.0 - _t)
	visual.position.y = -arc_height * arc
	shadow.scale = Vector2.ONE * (1.0 - 0.35 * arc)

	if _t >= 1.0:
		_flying = false
		visual.position.y = 0.0
		shadow.scale = Vector2.ONE
		set_process(false)
		landed.emit(self)
