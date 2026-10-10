extends Node2D
class_name FeatherCollector

@export_range(0.1, 10.0, 0.1) var base_collection_duration: float = 3.0
@export_range(4.0, 128.0, 1.0) var base_cursor_radius: float = 34.0
@export_range(0.1, 10.0, 0.1) var minimum_collection_duration: float = 0.5

var current_feather: Feather
var collection_elapsed: float = 0.0


func _process(delta: float) -> void:
	if ProgressionManager.get_effect_value(&"auto_collect") > 0.0:
		_reset_current_feather()
		_collect_all_feathers()
		return

	var candidate := _find_feather_under_cursor(get_global_mouse_position())
	if candidate != current_feather:
		_reset_current_feather()
		current_feather = candidate
		collection_elapsed = 0.0
	if not is_instance_valid(current_feather):
		return

	collection_elapsed = minf(collection_elapsed + delta, _get_collection_duration())
	_update_progress_visual()
	if collection_elapsed >= _get_collection_duration():
		_collect_current_feather()


func _get_collection_duration() -> float:
	var reduction := ProgressionManager.get_effect_value(&"feather_collect_time_reduction")
	return maxf(minimum_collection_duration, base_collection_duration - reduction)


func _get_cursor_radius() -> float:
	return maxf(base_cursor_radius, base_cursor_radius + ProgressionManager.get_effect_value(&"feather_collect_radius"))


func _find_feather_under_cursor(mouse_position: Vector2) -> Feather:
	var nearest: Feather
	var nearest_distance := _get_cursor_radius()
	for node in get_tree().get_nodes_in_group("collectible_feathers"):
		var feather := node as Feather
		if not is_instance_valid(feather) or not feather.is_visible_in_tree():
			continue
		var distance := mouse_position.distance_to(feather.global_position)
		if distance <= nearest_distance:
			nearest = feather
			nearest_distance = distance
	return nearest


func _update_progress_visual() -> void:
	if not is_instance_valid(current_feather):
		return
	var progress_back := current_feather.get_node_or_null("ProgressBack") as Polygon2D
	var progress_fill := current_feather.get_node_or_null("ProgressFill") as Polygon2D
	if progress_back == null or progress_fill == null:
		return
	progress_back.visible = true
	progress_fill.visible = true
	var fraction := clampf(collection_elapsed / _get_collection_duration(), 0.0, 1.0)
	progress_fill.scale.x = fraction


func _reset_current_feather() -> void:
	if is_instance_valid(current_feather):
		var progress_back := current_feather.get_node_or_null("ProgressBack") as Polygon2D
		var progress_fill := current_feather.get_node_or_null("ProgressFill") as Polygon2D
		if progress_back != null:
			progress_back.visible = false
		if progress_fill != null:
			progress_fill.visible = false
			progress_fill.scale.x = 0.0
	current_feather = null
	collection_elapsed = 0.0


func _collect_all_feathers() -> void:
	for node in get_tree().get_nodes_in_group("collectible_feathers"):
		var feather := node as Feather
		if is_instance_valid(feather) and feather.is_visible_in_tree():
			_collect_feather(feather)


func _collect_current_feather() -> void:
	if not is_instance_valid(current_feather):
		_reset_current_feather()
		return
	var feather := current_feather
	current_feather = null
	collection_elapsed = 0.0
	_collect_feather(feather)


func _collect_feather(feather: Feather) -> void:
	if not is_instance_valid(feather):
		return
	ProgressionManager.add_coin(feather.feather_value)
	feather.queue_free()
