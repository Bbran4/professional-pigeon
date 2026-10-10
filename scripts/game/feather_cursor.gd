extends Node2D
class_name FeatherCursor

@export var interaction_duration: float = 3.0
@export var cursor_radius: float = 34.0

var current_feather: Feather
var interaction_progress := 0.0


func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var nearest := _find_nearest_feather(mouse_position)

	if is_instance_valid(current_feather) and current_feather != nearest:
		_set_progress_visible(current_feather, false)
		interaction_progress = 0.0

	current_feather = nearest
	if not is_instance_valid(current_feather):
		interaction_progress = 0.0
		return

	interaction_progress += delta
	if interaction_progress >= interaction_duration:
		ProgressionManager.add_coin(current_feather.feather_value)
		current_feather.queue_free()
		current_feather = null
		interaction_progress = 0.0
		return

	_update_progress(current_feather)


func _find_nearest_feather(mouse_position: Vector2) -> Feather:
	var nearest: Feather
	var nearest_distance := cursor_radius
	for node in get_tree().get_nodes_in_group("collectible_feathers"):
		var feather := node as Feather
		if not is_instance_valid(feather):
			continue
		var distance := mouse_position.distance_to(feather.global_position)
		if distance <= nearest_distance:
			nearest = feather
			nearest_distance = distance
	return nearest


func _update_progress(feather: Feather) -> void:
	var back := feather.get_node_or_null("ProgressBack") as Polygon2D
	var fill := feather.get_node_or_null("ProgressFill") as Polygon2D
	if back != null:
		back.visible = true
	if fill != null:
		fill.visible = true
		var progress := clampf(interaction_progress / interaction_duration, 0.0, 1.0)
		fill.polygon = PackedVector2Array([
			Vector2(0, -2), Vector2(28.0 * progress, -2),
			Vector2(28.0 * progress, 2), Vector2(0, 2)
		])


func _set_progress_visible(feather: Feather, is_visible: bool) -> void:
	var back := feather.get_node_or_null("ProgressBack") as Polygon2D
	var fill := feather.get_node_or_null("ProgressFill") as Polygon2D
	if back != null:
		back.visible = is_visible
	if fill != null:
		fill.visible = is_visible
