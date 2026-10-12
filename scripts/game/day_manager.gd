extends Node
class_name DayManager

signal day_started(duration: float)
signal day_updated(time_remaining: float, points: int, pigeon_count: int, seeds_remaining: int, seeds_capacity: int)
signal day_ended(points: int)

@export var day_duration: float = 60.0

var time_remaining: float:
	get:
		return RunState.time_remaining

var points: int:
	get:
		return RunState.earned_feathers

var active: bool:
	get:
		return RunState.active

var _last_display_state: Array = []
var _last_timer_display: int = -1
var _feeders: Array[SeedFeeder] = []
var _collectibles: Array[Collectible] = []

var feeder: SeedFeeder:
	get:
		if is_instance_valid(_bench_feeder) and _bench_feeder.is_visible_in_tree():
			var bench_seed_feeder := _bench_feeder.get_node_or_null("SeedFeeder") as SeedFeeder
			if is_instance_valid(bench_seed_feeder):
				return bench_seed_feeder
		if not is_instance_valid(_feeder):
			_feeder = _starter_feeder
		return _feeder

var _feeder: SeedFeeder
@onready var _bench_feeder: BenchFeeder = get_node_or_null("../BenchFeeder") as BenchFeeder
@onready var _starter_feeder: SeedFeeder = get_node_or_null("../StarterFeeder") as SeedFeeder
@onready var spawner: PigeonSpawner = $"../PigeonSpawner"


func _ready() -> void:
	add_to_group("day_manager")
	spawner.visitor_count_changed.connect(_on_visitor_count_changed)
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	_connect_registry_signals()
	# Seed the registries for nodes that entered the tree before our signals
	# were connected. Registration callbacks are idempotent, so later signals
	# for the same nodes cannot create duplicates.
	for node in get_tree().get_nodes_in_group("feeders"):
		_register_feeder(node)
	for node in get_tree().get_nodes_in_group("collectibles"):
		_register_collectible(node)
	spawner.end_day()
	_emit_day_updated()


func _connect_registry_signals() -> void:
	if not DomainEvents.feeder_registered.is_connected(_register_feeder):
		DomainEvents.feeder_registered.connect(_register_feeder)
	if not DomainEvents.feeder_unregistered.is_connected(_unregister_feeder):
		DomainEvents.feeder_unregistered.connect(_unregister_feeder)
	if not DomainEvents.collectible_registered.is_connected(_register_collectible):
		DomainEvents.collectible_registered.connect(_register_collectible)
	if not DomainEvents.collectible_unregistered.is_connected(_unregister_collectible):
		DomainEvents.collectible_unregistered.connect(_unregister_collectible)


func _register_feeder(node: Node) -> void:
	var available_feeder := node as SeedFeeder
	if is_instance_valid(available_feeder) and not _feeders.has(available_feeder):
		_feeders.append(available_feeder)
		if not available_feeder.seeds_changed.is_connected(_on_feeder_seeds_changed):
			available_feeder.seeds_changed.connect(_on_feeder_seeds_changed)


func _unregister_feeder(node: Node) -> void:
	var available_feeder := node as SeedFeeder
	if not is_instance_valid(available_feeder):
		return
	if available_feeder.seeds_changed.is_connected(_on_feeder_seeds_changed):
		available_feeder.seeds_changed.disconnect(_on_feeder_seeds_changed)
	_feeders.erase(available_feeder)


func get_registered_feeders() -> Array[SeedFeeder]:
	var registered: Array[SeedFeeder] = _feeders.duplicate()
	return registered


func _register_collectible(node: Node) -> void:
	var collectible := node as Collectible
	if is_instance_valid(collectible) and not _collectibles.has(collectible):
		_collectibles.append(collectible)


func _unregister_collectible(node: Node) -> void:
	var collectible := node as Collectible
	if is_instance_valid(collectible):
		_collectibles.erase(collectible)


func _on_feeder_seeds_changed(_current: int, _capacity: int) -> void:
	_emit_day_updated()


func refresh_display() -> void:
	_last_display_state.clear()
	_last_timer_display = -1
	_emit_day_updated()


func _process(delta: float) -> void:
	if not active:
		return
	RunState.advance_time(delta)
	var timer_display := ceili(time_remaining)
	if timer_display != _last_timer_display:
		_emit_day_updated()
	if time_remaining <= 0.0:
		end_day()
		return
	_check_day_completion()


func start_day() -> void:
	if active:
		return
	_clear_uncollected_feathers()
	for available_feeder in _feeders:
		if is_instance_valid(available_feeder) and available_feeder.is_visible_in_tree():
			available_feeder.refill(available_feeder.get_seed_capacity())
	if not is_instance_valid(feeder):
		if is_instance_valid(_feeder):
			_feeder.refill(_feeder.get_seed_capacity())
	var duration := day_duration + ProgressionManager.get_effect_value(EffectIds.DAY_DURATION_ADD)
	RunState.begin_day(duration)
	_last_timer_display = -1
	spawner.start_day()
	day_started.emit(time_remaining)
	_emit_day_updated()


func collect_feather_points(amount: int) -> void:
	if not active or amount <= 0:
		return
	RunState.add_feathers(amount)
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
	for available_feeder in _feeders:
		if is_instance_valid(available_feeder) and available_feeder.is_visible_in_tree() and available_feeder.seeds_remaining < available_feeder.get_seed_capacity():
			return true
	return is_instance_valid(feeder) and feeder.is_visible_in_tree() and feeder.seeds_remaining < feeder.get_seed_capacity()


func _has_available_food() -> bool:
	for available_feeder in _feeders:
		if is_instance_valid(available_feeder) and available_feeder.is_visible_in_tree() and available_feeder.seeds_remaining > 0:
			return true
	return is_instance_valid(feeder) and feeder.is_visible_in_tree() and feeder.seeds_remaining > 0


func _has_uncollected_feathers() -> bool:
	for collectible in _collectibles:
		if is_instance_valid(collectible) and collectible.is_visible_in_tree():
			return true
	return false


func _clear_uncollected_feathers() -> void:
	for collectible in _collectibles:
		if is_instance_valid(collectible):
			collectible.queue_free()


func _on_visitor_count_changed(_count: int) -> void:
	_check_day_completion()
	_emit_day_updated()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	refresh_display()


func end_day() -> void:
	if not active:
		return
	var reward := RunState.finish_day()
	spawner.end_day()
	_clear_uncollected_feathers()
	if OS.is_debug_build():
		print("Day complete: earned %d Feathers." % reward)
	ProgressionManager.add_points(reward)
	ProgressionManager.save_game()
	_emit_day_updated()
	day_ended.emit(reward)
	DomainEvents.run_completed.emit(reward)


func _emit_day_updated() -> void:
	var seeds := 0
	var capacity := 0
	for available_feeder in _feeders:
		if is_instance_valid(available_feeder) and available_feeder.is_visible_in_tree():
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
	_last_timer_display = displayed_time
	day_updated.emit(
		time_remaining if active else 0.0,
		points,
		pigeon_count,
		seeds,
		capacity
	)
