extends Node2D
class_name FeatherCollector

@export_range(0.1, 10.0, 0.1) var collection_duration: float = 3.0
@export_range(4.0, 128.0, 1.0) var cursor_radius: float = 34.0

var current_feather: Feather
var collection_elapsed: float = 0.0


func _process(delta: float) -> void:
	var candidate := _find_feather_under_cursor(get_global_mouse_position())

	if candidate != current_feather:
		_reset_current_feather()
		current_feather = candidate
		collection_elapsed = 0.0

	if not is_instance_valid(current_feather):
		return

	collection_elapsed = minf(collection_elapsed + delta, collection_duration)
	_update_progress_visual()

	if collection_elapsed >= collection_duration:
		_collect_current_feather()


func _find_feather_under_cursor(mouse_position: Vector2) -> Feather:
	var nearest: Feather
	var nearest_distance := cursor_radius

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

	var fraction := clampf(collection_elapsed / collection_duration, 0.0, 1.0)
	var width := 28.0 * fraction
	progress_fill.polygon = PackedVector2Array([
		Vector2(0.0, -2.0),
		Vector2(width, -2.0),
		Vector2(width, 2.0),
		Vector2(0.0, 2.0),
	])


func _reset_current_feather() -> void:
	if is_instance_valid(current_feather):
		var progress_back := current_feather.get_node_or_null("ProgressBack") as Polygon2D
		var progress_fill := current_feather.get_node_or_null("ProgressFill") as Polygon2D
		if progress_back != null:
			progress_back.visible = false
		if progress_fill != null:
			progress_fill.visible = false

	current_feather = null
	collection_elapsed = 0.0


func _collect_current_feather() -> void:
	if not is_instance_valid(current_feather):
		_reset_current_feather()
		return

	var reward := current_feather.feather_value
	current_feather.queue_free()
	current_feather = null
	collection_elapsed = 0.0
	ProgressionManager.add_coin(reward)
