extends Node
class_name DayManager

signal day_started(duration: float)
signal day_updated(time_remaining: float, points: int, pigeon_count: int, seeds_remaining: int, seeds_capacity: int)
signal day_ended(points: int)

@export var day_duration: float = 60.0

var time_remaining: float = 0.0
var points: int = 0
var active: bool = false
var _last_display_state: Array = []

var feeder: SeedFeeder:
	get:
		var bench := get_node_or_null("../BenchFeeder") as BenchFeeder
		if is_instance_valid(bench) and bench.is_visible_in_tree():
			var bench_seed_feeder := bench.get_node_or_null("SeedFeeder") as SeedFeeder
			if is_instance_valid(bench_seed_feeder):
				return bench_seed_feeder
		if not is_instance_valid(_feeder):
			_feeder = get_node_or_null("../StarterFeeder") as SeedFeeder
		return _feeder

var _feeder: SeedFeeder

@onready var spawner: PigeonSpawner = $"../PigeonSpawner"


func _ready() -> void:
	add_to_group("day_manager")
	spawner.visitor_count_changed.connect(_on_visitor_count_changed)
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	spawner.end_day()
	_emit_day_updated()


func refresh_display() -> void:
	_last_display_state.clear()
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
	_clear_uncollected_feathers()
	for node in get_tree().get_nodes_in_group("feeders"):
		var available_feeder := node as SeedFeeder
		if available_feeder != null and available_feeder.is_visible_in_tree():
			available_feeder.refill(available_feeder.get_seed_capacity())
	if not is_instance_valid(feeder):
		if is_instance_valid(_feeder):
			_feeder.refill(_feeder.get_seed_capacity())
	points = 0
	time_remaining = day_duration + ProgressionManager.get_effect_value(EffectIds.DAY_DURATION_ADD)
	active = true
	spawner.start_day()
	day_started.emit(time_remaining)
	_emit_day_updated()


func collect_feather_points(amount: int) -> void:
	if not active or amount <= 0:
		return
	points += amount
	_emit_day_updated()


func _check_day_completion() -> void:
	if not active or time_remaining <= 0.0:
		return
	if _has_available_food() or spawner.get_active_count() > 0:
		return
	if _has_regenerating_feeder():
		return
	if _has_uncollected_feathers():
		return
	end_day()


func _has_regenerating_feeder() -> bool:
	var regen_interval := ProgressionManager.get_effect_value(EffectIds.SEED_REGEN_INTERVAL) - ProgressionManager.get_effect_value(EffectIds.SEED_REGEN_INTERVAL_REDUCTION)
	if regen_interval <= 0.0:
		return false
	for node in get_tree().get_nodes_in_group("feeders"):
		var available_feeder := node as SeedFeeder
		if available_feeder != null and available_feeder.is_visible_in_tree() and available_feeder.seeds_remaining < available_feeder.get_seed_capacity():
			return true
	return is_instance_valid(feeder) and feeder.is_visible_in_tree() and feeder.seeds_remaining < feeder.get_seed_capacity()


func _has_available_food() -> bool:
	for node in get_tree().get_nodes_in_group("feeders"):
		var available_feeder := node as SeedFeeder
		if available_feeder != null and available_feeder.is_visible_in_tree() and available_feeder.seeds_remaining > 0:
			return true
	return is_instance_valid(feeder) and feeder.is_visible_in_tree() and feeder.seeds_remaining > 0


func _has_uncollected_feathers() -> bool:
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if is_instance_valid(collectible) and collectible.is_visible_in_tree():
			return true
	return false


func _clear_uncollected_feathers() -> void:
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if is_instance_valid(collectible):
			collectible.queue_free()


func _on_visitor_count_changed(_count: int) -> void:
	_check_day_completion()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	refresh_display()


func end_day() -> void:
	if not active:
		return
	active = false
	spawner.end_day()
	_clear_uncollected_feathers()
	if OS.is_debug_build():
		print("Day complete: earned %d Feathers." % points)
	ProgressionManager.add_points(points)
	ProgressionManager.save_game()
	_emit_day_updated()
	day_ended.emit(points)


func _emit_day_updated() -> void:
	var seeds := 0
	var capacity := 0
	for node in get_tree().get_nodes_in_group("feeders"):
		var available_feeder := node as SeedFeeder
		if available_feeder != null and available_feeder.is_visible_in_tree():
			seeds += available_feeder.seeds_remaining
			capacity += available_feeder.get_seed_capacity()
	if capacity == 0 and is_instance_valid(feeder):
		seeds = feeder.seeds_remaining
		capacity = feeder.get_seed_capacity()
	var pigeon_count := spawner.get_active_count() if is_instance_valid(spawner) else 0
	var displayed_time := ceili(time_remaining) if active else 0
	var display_state: Array = [displayed_time, points, pigeon_count, seeds, capacity]
	if display_state == _last_display_state:
		return
	_last_display_state = display_state
	day_updated.emit(
		time_remaining if active else 0.0,
		points,
		pigeon_count,
		seeds,
		capacity
	)
