extends Actor
class_name Pigeon

signal flapped(from_ground: bool)
signal landed(impact_speed: float)

@export var stats: PigeonStats
var flap_held: bool = false
var facing: int = 1

var _flap_cut_armed: bool = false
var _was_on_floor: bool = false
var _peak_fall_speed: float = 0.0


func _ready() -> void:
	super._ready()
	if stats == null:
		stats = PigeonStats.new()


func _physics_process(_delta: float) -> void:
	var on_floor := is_on_floor()

	if on_floor:
		if not _was_on_floor:
			landed.emit(_peak_fall_speed)
			_peak_fall_speed = 0.0
	else:
		_peak_fall_speed = maxf(_peak_fall_speed, velocity.y)

	if _flap_cut_armed and not flap_held and velocity.y < 0.0:
		velocity.y *= stats.flap_release_cut
		_flap_cut_armed = false
	elif velocity.y >= 0.0:
		_flap_cut_armed = false

	_was_on_floor = on_floor


func get_move_speed() -> float:
	return stats.walk_speed


func update_facing() -> void:
	super.update_facing()
	if move_direction.x != 0.0:
		facing = 1 if move_direction.x > 0.0 else -1


func try_flap() -> bool:
	var from_ground := is_on_floor()
	velocity.y = -stats.flap_strength
	_flap_cut_armed = true
	flapped.emit(from_ground)
	return true


func steer_horizontal(max_speed: float, acceleration: float, friction: float, delta: float) -> void:
	var input := move_direction.x
	var target := input * max_speed
	var rate: float

	if absf(velocity.x) > max_speed and (input == 0.0 or signf(input) == signf(velocity.x)):
		rate = stats.overspeed_friction
	elif input != 0.0 and velocity.x != 0.0 and signf(input) != signf(velocity.x):
		rate = acceleration * stats.turn_multiplier
	elif input != 0.0:
		rate = acceleration
	else:
		rate = friction

	velocity.x = move_toward(velocity.x, target, rate * delta)


func ground_move(delta: float) -> void:
	steer_horizontal(get_move_speed(), stats.ground_acceleration, stats.ground_friction, delta)
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y = minf(velocity.y + stats.gravity * delta, stats.max_fall_speed)
	move_and_slide()


func air_move(delta: float) -> void:
	_apply_air_gravity(delta)
	steer_horizontal(stats.flight_speed, stats.air_acceleration, stats.air_friction, delta)
	move_and_slide()


func _apply_air_gravity(delta: float) -> void:
	var g := stats.gravity * gravity_scale
	if flap_held and absf(velocity.y) < stats.apex_threshold:
		g *= stats.apex_gravity_multiplier
	elif velocity.y > 0.0:
		g *= stats.fall_gravity_multiplier

	velocity.y = minf(velocity.y + g * delta, stats.max_fall_speed)
