extends Node2D
class_name SeedFeeder

const BALANCE: GameBalance = preload("res://data/game_balance.tres")

signal seeds_changed(current: int, capacity: int)
signal depleted

@export_range(1, 100, 1) var seed_capacity: int = 5
@export_range(0, 100, 1) var starting_seeds: int = 5

var seeds_remaining: int = 0
var _regen_elapsed := 0.0
var _last_capacity: int = 0
var _day_manager: DayManager


func _ready() -> void:
	_last_capacity = get_seed_capacity()
	seeds_remaining = mini(starting_seeds, _last_capacity)
	_update_visual()
	seeds_changed.emit(seeds_remaining, _last_capacity)
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	# Resolve after all nodes have completed _ready(), so scene-tree order
	# cannot leave us with a missing DayManager reference.
	call_deferred("_cache_day_manager")


func _cache_day_manager() -> void:
	_day_manager = get_tree().get_first_node_in_group("day_manager") as DayManager


func _process(delta: float) -> void:
	if not is_instance_valid(_day_manager) or not _day_manager.active:
		_regen_elapsed = 0.0
		return
	var regen_interval := ProgressionManager.get_effect_value(EffectIds.SEED_REGEN_INTERVAL) - ProgressionManager.get_effect_value(EffectIds.SEED_REGEN_INTERVAL_REDUCTION)
	if regen_interval <= 0.0 or seeds_remaining >= get_seed_capacity():
		_regen_elapsed = 0.0
		return
	_regen_elapsed += delta
	if _regen_elapsed >= regen_interval:
		_regen_elapsed = 0.0
		refill(1)


func get_seed_capacity() -> int:
	var capacity := seed_capacity + int(ProgressionManager.get_effect_value(EffectIds.SEED_CAPACITY_ADD))
	if ProgressionManager.get_effect_value(EffectIds.UNLOCK_SEEDS) > 0.0:
		capacity += int(ProgressionManager.get_effect_value(EffectIds.SEEDS_SPAWNS))
	return capacity


func can_feed() -> bool:
	return seeds_remaining > 0


func prepare_seed() -> Dictionary:
	return {
		"golden": randf() < ProgressionManager.get_effect_value(EffectIds.GOLDEN_SEED_CHANCE),
		"worm": ProgressionManager.get_effect_value(EffectIds.UNLOCK_WORMS) > 0.0 and randf() < BALANCE.worm_chance + ProgressionManager.get_effect_value(EffectIds.WORMS_SPAWNS) * BALANCE.worm_chance_per_upgrade,
	}


func consume_seed() -> bool:
	if seeds_remaining <= 0:
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
		label.text = "%d seeds" % seeds_remaining
