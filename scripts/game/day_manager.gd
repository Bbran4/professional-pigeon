extends Node
class_name DayManager

signal day_started(duration: float)
signal day_updated(time_remaining: float, points: int, pigeon_count: int, bread_remaining: int, bread_capacity: int)
signal day_ended(points: int)

@export var day_duration: float = 60.0

var time_remaining: float = 0.0
var points: int = 0
var active: bool = false
var food_remaining := 0

@onready var brain: ParkPigeonBrain = $"../Player/ParkPigeonBrain"
@onready var thrower: BreadThrower = $"../BreadThrower"


func _ready() -> void:
	thrower.bread_landed.connect(_on_bread_landed)
	brain.ate_food.connect(_on_pigeon_ate_food)
	brain.end_day()
	day_updated.emit(time_remaining, points, 1, 0, 0)


func _process(delta: float) -> void:
	if not active:
		return

	time_remaining = maxf(time_remaining - delta, 0.0)
	day_updated.emit(
		time_remaining,
		points,
		1,
		thrower.bread_remaining,
		thrower.get_stock_capacity()
	)

	# The timer is only a pacing display. A day completes when the player has
	# used all available bread and every piece of placed food has been eaten.
	_check_day_completion()


func start_day() -> void:
	if ProgressionManager.get_skill_level(&"bread") <= 0:
		return
	if active:
		return

	points = 0
	food_remaining = 0
	time_remaining = day_duration
	active = true

	thrower.start_day()
	brain.start_day(Vector2(185, 185))

	day_started.emit(day_duration)
	day_updated.emit(
		time_remaining,
		points,
		1,
		thrower.bread_remaining,
		thrower.get_stock_capacity()
	)


func add_points(amount: int) -> void:
	if not active or amount <= 0:
		return

	points += amount
	day_updated.emit(
		time_remaining,
		points,
		1,
		thrower.bread_remaining,
		thrower.get_stock_capacity()
	)


func _on_bread_landed(bread: ThrownBread) -> void:
	if not active:
		return

	food_remaining += 1
	brain.set_food(bread)
	_check_day_completion()


func _on_pigeon_ate_food(amount: int) -> void:
	food_remaining = maxi(food_remaining - 1, 0)
	add_points(amount)
	_check_day_completion()


func _check_day_completion() -> void:
	if not active:
		return

	# bread_remaining reaches zero when the player has thrown every available
	# piece. We also wait for any bread still in flight to land before checking
	# food_remaining, so the final throw cannot end the day prematurely.
	if thrower.bread_remaining > 0:
		return
	if thrower.has_active_bread():
		return
	if food_remaining > 0:
		return

	end_day()


func end_day() -> void:
	if not active:
		return

	active = false
	thrower.end_day()
	brain.end_day()

	# Day points become persistent Food that can be spent in the skill tree.
	ProgressionManager.add_food(points)

	day_updated.emit(0.0, points, 1, 0, 0)
	day_ended.emit(points)
