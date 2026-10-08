extends Node
class_name DayManager

signal day_started(duration: float)
signal day_updated(time_remaining: float, points: int, pigeon_count: int)
signal day_ended(points: int)

@export var day_duration: float = 60.0
var time_remaining: float = 0.0
var points: int = 0
var active: bool = false

@onready var pigeon: ParkPigeon = $"../ParkPigeon"
@onready var bread: Node2D = $"../Bread"

func _ready() -> void:
	bread.hide()
	pigeon.end_day()
	day_updated.emit(time_remaining, points, 1)

func _process(delta: float) -> void:
	if not active:
		return
	time_remaining = maxf(time_remaining - delta, 0.0)
	day_updated.emit(time_remaining, points, 1)
	if time_remaining <= 0.0:
		end_day()

func start_day() -> void:
	if active:
		return
	points = 0
	time_remaining = day_duration
	active = true
	bread.show()
	pigeon.start_day(bread)
	day_started.emit(day_duration)
	day_updated.emit(time_remaining, points, 1)

func add_points(amount: int) -> void:
	if not active or amount <= 0:
		return
	points += amount
	day_updated.emit(time_remaining, points, 1)

func end_day() -> void:
	if not active:
		return
	active = false
	pigeon.end_day()
	bread.hide()
	day_updated.emit(0.0, points, 1)
	day_ended.emit(points)
