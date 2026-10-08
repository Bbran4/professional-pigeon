extends Actor
class_name Pigeon

@export var stats: PigeonStats
var facing: int = 1


func _ready() -> void:
	super._ready()
	if stats == null:
		stats = PigeonStats.new()


func move_top_down(direction: Vector2, speed: float, delta: float) -> void:
	var target_velocity := direction.normalized() * speed if direction.length_squared() > 0.0 else Vector2.ZERO
	velocity = velocity.move_toward(target_velocity, stats.turn_speed * delta)
	move_and_slide()


func stop() -> void:
	velocity = velocity.move_toward(Vector2.ZERO, stats.turn_speed * get_physics_process_delta_time())
	move_and_slide()


func update_facing() -> void:
	super.update_facing()
	if move_direction.x != 0.0:
		facing = 1 if move_direction.x > 0.0 else -1
