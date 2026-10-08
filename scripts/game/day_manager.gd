extends Node
class_name DayManager

signal day_started(duration: float)
signal day_updated(time_remaining: float, points: int, pigeon_count: int)
signal day_ended(points: int)

@export var day_duration: float = 10.0

var time_remaining: float = 0.0
var points: int = 0
var active: bool = false
var food_remaining := 0
var feeding_finished := false

@onready var brain: ParkPigeonBrain = $"../Player/ParkPigeonBrain"
@onready var feeder: HumanFeeder = $"../HumanFeeder"

func _ready() -> void:
	brain.ate_food.connect(_on_pigeon_ate_food)
	feeder.bread_thrown.connect(_on_bread_thrown)
	feeder.feeding_finished.connect(_on_feeding_finished)
	brain.end_day()
	day_updated.emit(time_remaining, points, 1)

func _process(delta: float) -> void:
	if not active:
		return

	time_remaining = maxf(time_remaining - delta, 0.0)
	day_updated.emit(time_remaining, points, 1)

	if time_remaining <= 0.0:
		end_day()

	if feeding_finished and food_remaining <= 0:
		end_day()

func start_day() -> void:
	if active:
		return

	points = 0
	food_remaining = 0
	feeding_finished = false
	time_remaining = day_duration
	active = true

	feeder.start_day()
	brain.start_day(Vector2(185, 250))

	day_started.emit(day_duration)
	day_updated.emit(time_remaining, points, 1)

func add_points(amount: int) -> void:
	if not active or amount <= 0:
		return

	points += amount
	day_updated.emit(time_remaining, points, 1)

func _on_bread_thrown(bread: Node2D) -> void:
	if not active:
		bread.hide()
		return
	food_remaining += 1
	brain.set_food(bread)

func _on_feeding_finished() -> void:
	feeding_finished = true
	if food_remaining <= 0:
		end_day()

func _on_pigeon_ate_food(amount: int) -> void:
	food_remaining = maxi(food_remaining - 1, 0)
	add_points(amount)

func end_day() -> void:
	if not active:
		return

	active = false
	feeder.end_day()
	brain.end_day()

	day_updated.emit(0.0, points, 1)
	day_ended.emit(points)
