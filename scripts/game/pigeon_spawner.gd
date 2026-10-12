extends Node2D
class_name PigeonSpawner

signal ate_food(points: int)
signal visitor_count_changed(count: int)

@export var pigeon_scene: PackedScene
@export var feeder: SeedFeeder
@export var arrival_interval: float = 0.25
@export var park_layout: ParkLayout

const BALANCE: GameBalance = preload("res://data/game_balance.tres")

var day_active := false
var visitors: Array[VisitorRecord] = []
var perch_allocator := PerchAllocator.new()
var collectible_drops := CollectibleDropService.new()
var _pending_points_by_pigeon: Dictionary = {}
var _spawn_delay_pending := false
var _retry := 0.0


func _ready() -> void:
	set_process(false)
	if feeder == null:
		feeder = get_parent().get_node_or_null("StarterFeeder") as SeedFeeder
	if park_layout == null:
		park_layout = get_parent().get_node_or_null("ParkLayout") as ParkLayout
	if park_layout == null:
		push_error("PigeonSpawner: ParkLayout is required to provide park bounds and spawn positions.")
		return
	perch_allocator.configure(park_layout, get_parent() as Node2D)
	collectible_drops.configure(get_parent())


func start_day() -> void:
	if day_active:
		return
	day_active = true
	_spawn_available_visitors()


func end_day() -> void:
	# A day ending stops arrivals and removes any visitors still in flight.
	day_active = false
	_spawn_delay_pending = false
	for visitor in visitors:
		var pigeon := visitor.pigeon
		if is_instance_valid(pigeon):
			pigeon.queue_free()
	visitors.clear()
	perch_allocator.reset()
	_pending_points_by_pigeon.clear()
	visitor_count_changed.emit(0)


func get_active_count() -> int:
	_prune_invalid_visitors()
	return visitors.size()


func _get_max_pigeons() -> int:
	# Upgrades control the active visitor cap. Park objects only provide visual
	# destinations; they never determine how many visitors may be active.
	return BALANCE.minimum_pigeons + int(ProgressionManager.get_effect_value(EffectIds.MAX_PIGEONS)) + int(ProgressionManager.get_effect_value(EffectIds.TREE_NESTS)) * BALANCE.tree_nest_pigeon_capacity


func _spawn_available_visitors() -> void:
	if not day_active or pigeon_scene == null or _spawn_delay_pending:
		return
	_prune_invalid_visitors()
	if visitors.size() >= _get_max_pigeons():
		return

	# Do not cap arrivals by seed count or available perch markers. Visitors
	# without food will wait for their patience timeout and then depart.
	var perch := perch_allocator.reserve_perch(get_tree())
	var food_source := _find_available_feeder()
	if not _spawn_visitor(perch, food_source):
		perch_allocator.release_perch(perch.key)
		return
	if visitors.size() < _get_max_pigeons():
		_spawn_next_after_delay()


func _spawn_visitor(perch: PerchReservation, food_source: SeedFeeder) -> bool:
	var pigeon := pigeon_scene.instantiate() as Pigeon
	if pigeon == null:
		push_error("PigeonSpawner: pigeon_scene root must be a Pigeon.")
		return false
	get_parent().add_child(pigeon)
	pigeon.z_index = 20
	pigeon.z_as_relative = false
	var brain := pigeon.get_node_or_null("ParkPigeonBrain") as ParkPigeonBrain
	if brain == null:
		push_error("PigeonSpawner: npc_pigeon.tscn must contain a ParkPigeonBrain child.")
		pigeon.queue_free()
		return false

	brain.patience_timeout = maxf(BALANCE.minimum_patience_timeout, brain.patience_timeout + ProgressionManager.get_effect_value(EffectIds.PIGEON_PATIENCE_ADD))
	if randf() < ProgressionManager.get_effect_value(EffectIds.RARE_VISITOR_CHANCE):
		brain.food_points += BALANCE.rare_visitor_bonus_points
	var perch_position: Vector2 = perch.position
	var from_left := randf() < 0.5
	var park := get_parent() as Node2D
	var bounds_start := park.to_global(park_layout.visitor_bounds.position)
	var bounds_end := park.to_global(park_layout.visitor_bounds.end)
	var arrival := Vector2(bounds_start.x - 35.0, perch_position.y - 80.0) if from_left else Vector2(bounds_end.x + 35.0, perch_position.y - 80.0)
	var exit := Vector2(bounds_end.x + 55.0, perch_position.y - 80.0) if from_left else Vector2(bounds_start.x - 55.0, perch_position.y - 80.0)
	var perch_key := perch.key

	brain.ate_food.connect(_on_ate_food.bind(pigeon))
	brain.feather_dropped.connect(_on_feather_dropped.bind(pigeon))
	brain.departed.connect(_on_visitor_departed.bind(pigeon, perch_key))
	visitors.append(VisitorRecord.new(pigeon, brain, perch_key))
	brain.start_day(perch_position, arrival, exit)
	DomainEvents.visitor_spawned.emit(pigeon)
	brain.set_food(food_source)
	visitor_count_changed.emit(visitors.size())
	return true


func _find_available_feeder() -> SeedFeeder:
	var available: Array[SeedFeeder] = []
	for node in get_tree().get_nodes_in_group("feeders"):
		var candidate := node as SeedFeeder
		if candidate == null or not candidate.is_visible_in_tree() or not candidate.can_feed():
			continue
		available.append(candidate)
	if available.is_empty():
		if is_instance_valid(feeder) and feeder.is_visible_in_tree() and feeder.can_feed():
			return feeder
		return null
	return available[randi_range(0, available.size() - 1)]


func _on_ate_food(points: int, pigeon: Pigeon) -> void:
	_pending_points_by_pigeon[pigeon.get_instance_id()] = points


func _on_feather_dropped(drop_position: Vector2, pigeon: Pigeon) -> void:
	var point_reward := int(_pending_points_by_pigeon.get(pigeon.get_instance_id(), 0))
	_pending_points_by_pigeon.erase(pigeon.get_instance_id())
	collectible_drops.spawn_visit_feathers(drop_position, point_reward)


func _on_visitor_departed(pigeon: Pigeon, perch_key: String) -> void:
	for index in range(visitors.size() - 1, -1, -1):
		var visitor: VisitorRecord = visitors[index]
		if visitor.pigeon == pigeon:
			visitors.remove_at(index)
			break
	perch_allocator.release_perch(perch_key)
	if is_instance_valid(pigeon):
		DomainEvents.visitor_departed.emit(pigeon)
		pigeon.queue_free()
	visitor_count_changed.emit(visitors.size())
	if day_active:
		_spawn_next_after_delay()


func _spawn_next_after_delay() -> void:
	if _spawn_delay_pending:
		return
	_spawn_delay_pending = true
	var delay := maxf(BALANCE.minimum_spawn_delay, arrival_interval - ProgressionManager.get_effect_value(EffectIds.ARRIVAL_SPEED_REDUCTION) - ProgressionManager.get_effect_value(EffectIds.FOUNTAIN_UNLOCK) * BALANCE.fountain_spawn_delay_reduction)
	if randf() < ProgressionManager.get_effect_value(EffectIds.PAIR_ARRIVALS):
		delay = 0.0
	get_tree().create_timer(delay).timeout.connect(_on_spawn_delay_timeout, CONNECT_ONE_SHOT)


func _on_spawn_delay_timeout() -> void:
	if not is_inside_tree():
		return
	_spawn_delay_pending = false
	if day_active:
		_spawn_available_visitors()


func _prune_invalid_visitors() -> void:
	for index in range(visitors.size() - 1, -1, -1):
		var visitor: VisitorRecord = visitors[index]
		var pigeon := visitor.pigeon
		if is_instance_valid(pigeon):
			continue
		perch_allocator.release_perch(visitor.perch_key)
		visitors.remove_at(index)
