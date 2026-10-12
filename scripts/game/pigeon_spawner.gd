extends Node2D
class_name PigeonSpawner

signal ate_food(points: int)
signal visitor_count_changed(count: int)

@export var pigeon_scene: PackedScene
@export var feeder: SeedFeeder
@export var park_layout: ParkLayout

const BALANCE: GameBalance = preload("res://data/game_balance.tres")

var day_active := false
var visitors: Array[VisitorRecord] = []
var perch_allocator := PerchAllocator.new()
var collectible_drops := CollectibleDropService.new()
var _pending_points_by_pigeon: Dictionary = {}
var _spawn_delay_pending := false
var _spawn_generation: int = 0
var _retry := 0.0


func _ready() -> void:
	set_process(false)
	if feeder == null:
		feeder = get_parent().get_node_or_null("StarterFeeder") as SeedFeeder
	if park_layout == null:
		park_layout = get_parent().get_node_or_null("ParkLayout") as ParkLayout
	if pigeon_scene == null:
		push_error("PigeonSpawner '%s': pigeon_scene is not assigned. Assign scenes/park/npc_pigeon.tscn in the Inspector." % get_path())
		set_process(false)
		return
	if park_layout == null:
		push_error("PigeonSpawner '%s': ParkLayout is missing. Add a ParkLayout node under the park and assign it in the Inspector, or name the child 'ParkLayout'." % get_path())
		set_process(false)
		return
	if not pigeon_scene.can_instantiate():
		push_error("PigeonSpawner '%s': pigeon_scene cannot be instantiated. Re-select a valid Pigeon scene in the Inspector." % get_path())
		set_process(false)
		return
	if not is_instance_valid(feeder):
		push_warning("PigeonSpawner '%s': no StarterFeeder was found or assigned. Pigeons can arrive without food until a feeder is registered." % get_path())
	perch_allocator.configure(park_layout, get_parent() as Node2D)
	collectible_drops.configure(get_parent())


func _exit_tree() -> void:
	# Invalidate any timer callback that may fire after this spawner leaves
	# the scene tree. The timer itself can finish harmlessly.
	day_active = false
	_spawn_generation += 1
	_spawn_delay_pending = false


func start_day() -> void:
	if not is_inside_tree() or day_active:
		return
	_spawn_generation += 1
	_spawn_delay_pending = false
	day_active = true
	_spawn_available_visitors()


func end_day() -> void:
	# Invalidate outstanding arrivals before cleaning up current visitors.
	day_active = false
	_spawn_generation += 1
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
	if not is_inside_tree() or not day_active or pigeon_scene == null or _spawn_delay_pending:
		return
	_prune_invalid_visitors()
	if visitors.size() >= _get_max_pigeons():
		return

	# Do not cap arrivals by seed count or available perch markers. Visitors
	# without food will wait for their patience timeout and then depart.
	var perch := perch_allocator.reserve_perch(get_tree())
	if perch == null:
		push_error("PigeonSpawner: Could not reserve a landing position.")
		return
	var food_source := _find_available_feeder()
	if not _spawn_visitor(perch, food_source):
		perch_allocator.release_perch(perch.key)
		return
	if visitors.size() < _get_max_pigeons():
		_spawn_next_after_delay()


func _spawn_visitor(perch: PerchReservation, food_source: SeedFeeder) -> bool:
	if not is_inside_tree() or not day_active:
		return false
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
	var arrival_group: StringName = &"visitor_entry_left" if from_left else &"visitor_entry_right"
	var exit_group: StringName = &"visitor_exit_right" if from_left else &"visitor_exit_left"
	var bounds := park_layout.visitor_bounds
	var fallback_entry := Vector2(
		bounds.position.x - 75.0 if from_left else bounds.end.x + 75.0,
		bounds.position.y + 80.0
	)
	var fallback_exit := Vector2(
		bounds.end.x + 95.0 if from_left else bounds.position.x - 95.0,
		bounds.position.y + 80.0
	)
	var arrival := _get_spawn_position(arrival_group, fallback_entry)
	var exit := _get_spawn_position(exit_group, fallback_exit)
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
	if day_active and is_inside_tree():
		_spawn_next_after_delay()


func _spawn_next_after_delay() -> void:
	if not is_inside_tree() or not day_active or _spawn_delay_pending:
		return
	_spawn_delay_pending = true
	var generation := _spawn_generation
	var delay := maxf(BALANCE.minimum_spawn_delay, BALANCE.default_arrival_interval - ProgressionManager.get_effect_value(EffectIds.ARRIVAL_SPEED_REDUCTION) - ProgressionManager.get_effect_value(EffectIds.FOUNTAIN_UNLOCK) * BALANCE.fountain_spawn_delay_reduction)
	if randf() < ProgressionManager.get_effect_value(EffectIds.PAIR_ARRIVALS):
		delay = 0.0
	get_tree().create_timer(delay).timeout.connect(_on_spawn_delay_timeout.bind(generation), CONNECT_ONE_SHOT)


func _on_spawn_delay_timeout(generation: int) -> void:
	# A completed day, a new day, or scene exit invalidates this callback.
	if generation != _spawn_generation or not is_inside_tree() or not day_active:
		return
	_spawn_delay_pending = false
	_spawn_available_visitors()


func _prune_invalid_visitors() -> void:
	for index in range(visitors.size() - 1, -1, -1):
		var visitor: VisitorRecord = visitors[index]
		var pigeon := visitor.pigeon
		if is_instance_valid(pigeon):
			continue
		perch_allocator.release_perch(visitor.perch_key)
		visitors.remove_at(index)


func _get_spawn_position(group_name: StringName, fallback_position: Vector2) -> Vector2:
	var candidates: Array[Marker2D] = []
	for node in get_tree().get_nodes_in_group(group_name):
		var marker := node as Marker2D
		if marker != null and marker.is_inside_tree() and marker.is_visible_in_tree():
			candidates.append(marker)
	if not candidates.is_empty():
		return candidates[randi_range(0, candidates.size() - 1)].global_position

	# Older/local copies of the park scene may not have the editor markers yet.
	# Keep the day playable using positions derived from ParkLayout until the
	# scene is synchronised with the marker-based layout.
	var park := get_parent() as Node2D
	if park == null:
		return fallback_position
	push_warning("PigeonSpawner: Missing '%s' marker group; using ParkLayout fallback position." % group_name)
	return park.to_global(fallback_position)
