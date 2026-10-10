extends Node2D
class_name SeedFeeder

signal seeds_changed(current: int, capacity: int)
signal depleted

@export_range(1, 100, 1) var seed_capacity: int = 5
@export var starting_seeds: int = 5

var seeds_remaining: int = 5
var _regen_elapsed := 0.0


func _process(delta: float) -> void:
	var day_manager := get_tree().get_first_node_in_group("day_manager") as DayManager
	if day_manager == null or not day_manager.active:
		_regen_elapsed = 0.0
		return
	var regen_interval := ProgressionManager.get_effect_value(&"seed_regen_interval")
	if regen_interval <= 0.0 or seeds_remaining >= get_seed_capacity():
		_regen_elapsed = 0.0
		return
	_regen_elapsed += delta
	if _regen_elapsed >= regen_interval:
		_regen_elapsed = 0.0
		refill(1)


func _ready() -> void:
	seeds_remaining = clampi(starting_seeds, 0, get_seed_capacity())
	_update_visual()
	seeds_changed.emit(seeds_remaining, get_seed_capacity())


func get_seed_capacity() -> int:
	var capacity := seed_capacity + int(ProgressionManager.get_effect_value(&"seed_capacity_add"))
	if ProgressionManager.get_effect_value(&"unlock_seeds") > 0.0:
		capacity += int(ProgressionManager.get_effect_value(&"seeds_spawns"))
	return capacity


func can_feed() -> bool:
	return seeds_remaining > 0


func consume_seed() -> bool:
	if seeds_remaining <= 0:
		return false
	seeds_remaining -= 1
	if randf() < ProgressionManager.get_effect_value(&"golden_seed_chance"):
		set_meta("last_seed_golden", true)
	else:
		set_meta("last_seed_golden", false)
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


func _update_visual() -> void:
	var seed_pile := get_node_or_null("SeedPile") as Polygon2D
	if seed_pile != null:
		seed_pile.visible = seeds_remaining > 0
	var label := get_node_or_null("SeedCount") as Label
	if label != null:
		label.text = "%d seeds" % seeds_remaining
