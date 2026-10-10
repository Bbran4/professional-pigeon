extends Node2D
class_name FeatherCollector

@export_range(0.1, 10.0, 0.1) var base_collection_duration: float = 3.0
@export_range(4.0, 128.0, 1.0) var base_cursor_radius: float = 34.0
@export_range(0.1, 10.0, 0.1) var minimum_collection_duration: float = 0.5

var current_collectible: Collectible
var collection_elapsed: float = 0.0
var crow_elapsed: float = 0.0


func _process(delta: float) -> void:
	var auto_collect := ProgressionManager.get_effect_value(&"auto_collect") > 0.0
	var crow_interval := ProgressionManager.get_effect_value(&"crow_collect_interval")
	if auto_collect:
		_collect_all_collectibles()
		return
	if crow_interval > 0.0:
		crow_elapsed += delta
		if crow_elapsed >= crow_interval:
			crow_elapsed = 0.0
			_collect_one_collectible()
	else:
		crow_elapsed = 0.0

	var candidate := _find_collectible_under_cursor(get_global_mouse_position())
	if candidate != current_collectible:
		_reset_current_collectible()
		current_collectible = candidate
		collection_elapsed = 0.0
	if not is_instance_valid(current_collectible):
		return

	collection_elapsed = minf(collection_elapsed + delta, _get_collection_duration())
	_update_progress_visual()
	if collection_elapsed >= _get_collection_duration():
		_collect_current_collectible()


func _get_collection_duration() -> float:
	var reduction := ProgressionManager.get_effect_value(&"feather_collect_time_reduction")
	return maxf(minimum_collection_duration, base_collection_duration - reduction)


func _get_cursor_radius() -> float:
	return maxf(4.0, base_cursor_radius + ProgressionManager.get_effect_value(&"feather_collect_radius"))


func _find_collectible_under_cursor(mouse_position: Vector2) -> Collectible:
	var nearest: Collectible
	var nearest_distance := _get_cursor_radius()
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if not is_instance_valid(collectible) or not collectible.is_visible_in_tree():
			continue
		var distance := mouse_position.distance_to(collectible.global_position)
		if distance <= nearest_distance:
			nearest = collectible
			nearest_distance = distance
	return nearest


func _update_progress_visual() -> void:
	if not is_instance_valid(current_collectible):
		return
	var progress_back := current_collectible.get_node_or_null("ProgressBack") as Polygon2D
	var progress_fill := current_collectible.get_node_or_null("ProgressFill") as Polygon2D
	if progress_back == null or progress_fill == null:
		return
	progress_back.visible = true
	progress_fill.visible = true
	var fraction := clampf(collection_elapsed / _get_collection_duration(), 0.0, 1.0)
	progress_fill.scale.x = fraction


func _reset_current_collectible() -> void:
	if is_instance_valid(current_collectible):
		var progress_back := current_collectible.get_node_or_null("ProgressBack") as Polygon2D
		var progress_fill := current_collectible.get_node_or_null("ProgressFill") as Polygon2D
		if progress_back != null:
			progress_back.visible = false
		if progress_fill != null:
			progress_fill.visible = false
			progress_fill.scale.x = 0.0
	current_collectible = null
	collection_elapsed = 0.0


func _collect_all_collectibles() -> void:
	_reset_current_collectible()
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if is_instance_valid(collectible) and collectible.is_visible_in_tree():
			_collect_collectible(collectible)


func _collect_one_collectible() -> void:
	for node in get_tree().get_nodes_in_group("collectibles"):
		var collectible := node as Collectible
		if is_instance_valid(collectible) and collectible.is_visible_in_tree():
			_collect_collectible(collectible)
			return


func _collect_current_collectible() -> void:
	if not is_instance_valid(current_collectible):
		_reset_current_collectible()
		return
	var collectible := current_collectible
	current_collectible = null
	collection_elapsed = 0.0
	_collect_collectible(collectible)


func _collect_collectible(collectible: Collectible) -> void:
	if not is_instance_valid(collectible) or not collectible.is_visible_in_tree():
		return
	collectible.hide()
	ProgressionManager.add_coin(collectible.coin_value)
	collectible.queue_free()
