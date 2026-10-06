extends Camera2D
class_name FollowCamera

@export var follow_speed: float = 5.0


func _ready() -> void:
	limit_left = int(WorldConfig.WORLD_LEFT)
	limit_right = int(WorldConfig.WORLD_RIGHT)
	limit_bottom = int(WorldConfig.GROUND_BOTTOM)
	limit_smoothed = true
	position_smoothing_speed = follow_speed
	position_smoothing_enabled = true
	reset_smoothing()
