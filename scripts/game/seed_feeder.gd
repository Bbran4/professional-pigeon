extends Node2D
class_name SeedFeeder

const BALANCE: GameBalance = preload("res://data/game_balance.tres")
const FOOD_SCENE: PackedScene = preload("res://scenes/park/food_piece.tscn")

signal seeds_changed(current: int, capacity: int)
signal depleted

@export_range(1, 100, 1) var seed_capacity: int = 5
@export_range(0, 100, 1) var starting_seeds: int = 5
@export_enum("bread", "seeds") var food_kind: String = "bread"
@export_range(0.25, 5.0, 0.05) var throw_interval: float = 5.0
@export_range(20.0, 180.0, 5.0) var throw_distance: float = 82.0
@export_range(0.0, 60.0, 1.0) var throw_spread_degrees: float = 32.0

var seeds_remaining: int = 0
var gameplay_enabled := true
var _regen_elapsed := 0.0
var _throw_elapsed := 0.0
var _last_capacity: int = 0
var _day_manager: DayManager


func _ready() -> void:
	add_to_group("feeders")
	_last_capacity = get_seed_capacity()
	seeds_remaining = mini(starting_seeds, _last_capacity)
	_update_visual()
	seeds_changed.emit(seeds_remaining, _last_capacity)
	DomainEvents.feeder_registered.emit(self)
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	_refresh_processing_state()
	# Resolve after all nodes have completed _ready(), so scene-tree order
	# cannot leave us with a missing DayManager reference.
	call_deferred("_cache_day_manager")


func _exit_tree() -> void:
	DomainEvents.feeder_unregistered.emit(self)


func _cache_day_manager() -> void:
	_day_manager = get_tree().get_first_node_in_group("day_manager") as DayManager


func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		_refresh_processing_state()
		return
	gameplay_enabled = enabled
	if not gameplay_enabled:
		_regen_elapsed = 0.0
	_refresh_processing_state()


func _on_visibility_changed() -> void:
	_refresh_processing_state()


func _refresh_processing_state() -> void:
	set_process(gameplay_enabled and is_visible_in_tree())
	if not gameplay_enabled or not is_visible_in_tree():
		_regen_elapsed = 0.0
		_throw_elapsed = 0.0


func _process(delta: float) -> void:
	if not gameplay_enabled or not is_visible_in_tree():
		_regen_elapsed = 0.0
		_throw_elapsed = 0.0
		return
	if not is_instance_valid(_day_manager) or not _day_manager.active:
		_regen_elapsed = 0.0
		_throw_elapsed = 0.0
		return
	if seeds_remaining > 0:
		_throw_elapsed += delta
		if _throw_elapsed >= throw_interval:
			_throw_elapsed = 0.0
			_throw_food_piece()
	var regen_interval := ProgressionManager.get_effect_value(EffectIds.SEED_REGEN_INTERVAL) - ProgressionManager.get_effect_value(EffectIds.SEED_REGEN_INTERVAL_REDUCTION)
	if regen_interval <= 0.0 or seeds_remaining >= get_seed_capacity():
		_regen_elapsed = 0.0
		return
	_regen_elapsed += delta
	if _regen_elapsed >= regen_interval:
		_regen_elapsed = 0.0
		refill(1)


func get_seed_capacity() -> int:
	var capacity := seed_capacity
	if food_kind == "seeds":
		capacity += int(ProgressionManager.get_effect_value(EffectIds.SEED_CAPACITY_ADD))
	if food_kind == "seeds" and ProgressionManager.get_effect_value(EffectIds.UNLOCK_SEEDS) > 0.0:
		capacity += int(ProgressionManager.get_effect_value(EffectIds.SEEDS_SPAWNS))
	return capacity


func can_feed() -> bool:
	return gameplay_enabled and is_visible_in_tree() and seeds_remaining > 0


func prepare_seed() -> Dictionary:
	if not can_feed():
		return {}
	return {
		"golden": food_kind == "seeds" and randf() < ProgressionManager.get_effect_value(EffectIds.GOLDEN_SEED_CHANCE),
		"worm": food_kind == "seeds" and ProgressionManager.get_effect_value(EffectIds.UNLOCK_WORMS) > 0.0 and randf() < clampf(ProgressionManager.get_effect_value(EffectIds.UNLOCK_WORMS) + ProgressionManager.get_effect_value(EffectIds.WORMS_SPAWNS) * BALANCE.worm_chance_per_upgrade, 0.0, 1.0),
	}


func _throw_food_piece() -> void:
	if not can_feed():
		return
	var parent := get_parent()
	if parent == null:
		return
	var piece := FOOD_SCENE.instantiate() as FoodPiece
	if piece == null:
		push_error("SeedFeeder: food scene root must be FoodPiece.")
		return
	var traits := prepare_seed()
	piece.food_kind = food_kind
	piece.is_golden = bool(traits.get("golden", false))
	piece.is_worm = bool(traits.get("worm", false))
	piece.feeding_duration = 4.0 if food_kind == "seeds" else 1.0
	parent.add_child(piece)
	var spread := deg_to_rad(throw_spread_degrees)
	var angle := randf_range(-spread, spread)
	var direction := Vector2.DOWN.rotated(angle)
	piece.global_position = global_position + direction * randf_range(throw_distance * 0.65, throw_distance)
	if not consume_seed():
		piece.queue_free()


func consume_seed() -> bool:
	if not can_feed():
		return false
	seeds_remaining -= 1
	_update_visual()
	seeds_changed.emit(seeds_remaining, get_seed_capacity())
	if seeds_remaining == 0:
		depleted.emit()
	return true


func refill(amount: int) -> void:
	if amount <= 0:
		return
	var previous := seeds_remaining
	seeds_remaining = mini(get_seed_capacity(), seeds_remaining + amount)
	if seeds_remaining != previous:
		_update_visual()
		seeds_changed.emit(seeds_remaining, get_seed_capacity())


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	var capacity := get_seed_capacity()
	if capacity > _last_capacity:
		seeds_remaining = mini(capacity, seeds_remaining + capacity - _last_capacity)
	elif capacity < _last_capacity:
		seeds_remaining = mini(seeds_remaining, capacity)
	_last_capacity = capacity
	_update_visual()
	seeds_changed.emit(seeds_remaining, capacity)


func _update_visual() -> void:
	var seed_pile := get_node_or_null("SeedPile") as Polygon2D
	if seed_pile != null:
		seed_pile.visible = seeds_remaining > 0
	var label := get_node_or_null("SeedCount") as Label
	if label != null:
		label.text = "%d %s" % [seeds_remaining, food_kind]
