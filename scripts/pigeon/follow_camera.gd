extends Camera2D
class_name FollowCamera

@export var follow_speed: float = 5.0


func _ready() -> void:
	position_smoothing_enabled = false
	var half_view := get_viewport_rect().size / zoom * 0.5
	var player_position: Vector2 = get_parent().global_position
	global_position = Vector2(
		clampf(player_position.x, WorldConfig.WORLD_LEFT + half_view.x, WorldConfig.WORLD_RIGHT - half_view.x),
		minf(player_position.y, WorldConfig.GROUND_BOTTOM - half_view.y)
	)


func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size / zoom
	var half_width := viewport_size.x * 0.5
	var half_height := viewport_size.y * 0.5
	var player_position: Vector2 = get_parent().global_position

	var target_x := clampf(player_position.x, WorldConfig.WORLD_LEFT + half_width, WorldConfig.WORLD_RIGHT - half_width)
	var target_y := minf(player_position.y, WorldConfig.GROUND_BOTTOM - half_height)

	var blend := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(Vector2(target_x, target_y), blend)
