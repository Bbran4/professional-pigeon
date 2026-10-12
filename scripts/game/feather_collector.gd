extends Node2D
class_name FeatherCollector

@export_range(0.1, 10.0, 0.1) var base_collection_duration: float = 3.0
@export_range(4.0, 128.0, 1.0) var base_cursor_radius: float = 34.0
@export_range(0.1, 10.0, 0.1) var minimum_collection_duration: float = 0.5

const PICKUP_TEXT_DURATION := 0.75
const PICKUP_TEXT_RISE := 30.0

var current_collectible: Collectible
var collection_elapsed: float = 0.0
var crow_elapsed: float = 0.0
var _cursor_active := false


func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	var auto_collect := ProgressionManager.get_effect_value(EffectIds.AUTO_COLLECT) > 0.0
	var crow_interval := ProgressionManager.get_effect_value(EffectIds.CROW_COLLECT_INTERVAL)
	if auto_collect:
		_cursor_active = false
		_reset_current_collectible()
		queue_redraw()
		_collect_all_collectibles()
		return
	if crow_interval > 0.0:
		crow_elapsed += delta
		if crow_elapsed >= crow_interval:
			crow_elapsed = 0.0
			_collect_one_collectible()
	else:
		crow_elapsed = 0.0

	var mouse_position := get_global_mouse_position()
	if is_instance_valid(current_collectible):
		if not current_collectible.is_visible_in_tree() or mouse_position.distance_to(current_collectible.global_position) > _get_cursor_radius():
			_reset_current_collectible()

	if not is_instance_valid(current_collectible):
		current_collectible = _find_collectible_under_cursor(mouse_position)
		collection_elapsed = 0.0

	_cursor_active = is_instance_valid(current_collectible)
	if _cursor_active:
		collection_elapsed = minf(collection_elapsed + delta, _get_collection_duration())
		if collection_elapsed >= _get_collection_duration():
			_collect_current_collectible()
			_cursor_active = false
	queue_redraw()


func _draw() -> void:
	if not _cursor_active:
		return
	var radius := _get_cursor_radius()
	var center := Vector2.ZERO
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.12, 0.12, 0.12, 0.8), 3.0, true)
	var fraction := clampf(collection_elapsed / _get_collection_duration(), 0.0, 1.0)
	if fraction > 0.0:
		draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * fraction, 48, Color(0.95, 0.82, 0.38, 1.0), 4.0, true)


func _get_collection_duration() -> float:
	var reduction := ProgressionManager.get_effect_value(EffectIds.FEATHER_COLLECT_TIME_REDUCTION)
	return maxf(minimum_collection_duration, base_collection_duration - reduction)


func _get_cursor_radius() -> float:
	return maxf(4.0, base_cursor_radius + ProgressionManager.get_effect_value(EffectIds.FEATHER_COLLECT_RADIUS))


func _find_collectible_under_cursor(mouse_position: Vector2) -> Collectible:
	var candidates: Array[Collectible] = []
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if not is_instance_valid(collectible) or not collectible.is_visible_in_tree():
			continue
		if mouse_position.distance_to(collectible.global_position) <= _get_cursor_radius():
			candidates.append(collectible)
	if candidates.is_empty():
		return null
	return candidates[randi_range(0, candidates.size() - 1)]


func _reset_current_collectible() -> void:
	current_collectible = null
	collection_elapsed = 0.0


func _collect_all_collectibles() -> void:
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if is_instance_valid(collectible) and collectible.is_visible_in_tree():
			_collect_collectible(collectible)


func _collect_one_collectible() -> void:
	var candidates: Array[Collectible] = []
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if is_instance_valid(collectible) and collectible.is_visible_in_tree():
			candidates.append(collectible)
	if not candidates.is_empty():
		_collect_collectible(candidates[randi_range(0, candidates.size() - 1)])


func _collect_current_collectible() -> void:
	if not is_instance_valid(current_collectible):
		_reset_current_collectible()
		return
	var collectible := current_collectible
	_reset_current_collectible()
	_collect_collectible(collectible)


func _collect_collectible(collectible: Collectible) -> void:
	if not is_instance_valid(collectible) or not collectible.is_visible_in_tree():
		return
	var pickup_position := collectible.global_position
	var points := collectible.point_value
	DomainEvents.collectible_collected.emit(collectible, points)
	var is_golden := collectible is Feather and (collectible as Feather).is_golden
	_spawn_pickup_text(pickup_position, points, is_golden)
	collectible.hide()
	if points > 0:
		var day_manager := get_tree().get_first_node_in_group("day_manager") as DayManager
		if is_instance_valid(day_manager):
			day_manager.collect_feather_points(points)
	collectible.queue_free()


func _spawn_pickup_text(world_position: Vector2, points: int, is_golden: bool) -> void:
	var label := Label.new()
	label.name = "PickupFeedback"
	label.text = "+%d" % points
	label.add_theme_font_size_override("font_size", 20 if is_golden else 18)
	label.add_theme_color_override("font_color", Color(1.0, 0.76, 0.18, 1.0) if is_golden else Color(1.0, 0.97, 0.86, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.16, 0.12, 0.07, 0.95))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var world_parent := get_parent() as Node2D
	if world_parent == null:
		label.queue_free()
		return
	label.position = world_parent.to_local(world_position) - Vector2(18.0, 12.0)
	label.z_index = 100
	world_parent.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - PICKUP_TEXT_RISE, PICKUP_TEXT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, PICKUP_TEXT_DURATION).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(Callable(label, "queue_free"))
