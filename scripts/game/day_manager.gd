extends Node
class_name DayManager

signal day_started(duration: float)
signal day_updated(time_remaining: float, points: int, pigeon_count: int, bread_remaining: int, bread_capacity: int)
signal day_ended(points: int)

@export var day_duration: float = 60.0

var time_remaining: float = 0.0
var points: int = 0
var active: bool = false

var feeder: SeedFeeder:
	get:
		if not is_instance_valid(_feeder):
			_feeder = get_node_or_null("../BenchFeeder/SeedFeeder") as SeedFeeder
		return _feeder

var _feeder: SeedFeeder

@onready var spawner: PigeonSpawner = $"../PigeonSpawner"
@onready var bread_thrower: BreadThrower = $"../BreadThrower"


func _ready() -> void:
	spawner.ate_food.connect(_on_pigeon_ate_food)
	spawner.end_day()
	_emit_day_updated()


func _process(delta: float) -> void:
	if not active:
		return
	time_remaining = maxf(time_remaining - delta, 0.0)
	_emit_day_updated()
	if time_remaining <= 0.0:
		end_day()
		return
	_check_day_completion()


func start_day() -> void:
	if active:
		return
	if feeder.seeds_remaining <= 0:
		feeder.refill(feeder.get_seed_capacity())
	points = 0
	time_remaining = day_duration
	active = true
	spawner.start_day()
	bread_thrower.start_day()
	day_started.emit(day_duration)
	_emit_day_updated()


func _on_pigeon_ate_food(amount: int) -> void:
	if not active:
		return
	points += amount
	_emit_day_updated()


func _check_day_completion() -> void:
	if not active:
		return
	if feeder.seeds_remaining > 0:
		return
	if spawner.get_active_count() > 0:
		return
	if spawner.has_pending_food() or bread_thrower.has_active_bread():
		return
	end_day()


func end_day() -> void:
	if not active:
		return
	active = false
	spawner.end_day()
	bread_thrower.end_day()
	ProgressionManager.add_points(points)
	_emit_day_updated()
	day_ended.emit(points)


func _emit_day_updated() -> void:
	var seeds := feeder.seeds_remaining if is_instance_valid(feeder) else 0
	var capacity := feeder.get_seed_capacity() if is_instance_valid(feeder) else 0
	day_updated.emit(
		time_remaining if active else 0.0,
		points,
		spawner.get_active_count() if is_instance_valid(spawner) else 0,
		seeds,
		capacity
	)
