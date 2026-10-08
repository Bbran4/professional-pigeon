extends Actor
class_name Pigeon

signal flapped(from_ground: bool)
signal landed(impact_speed: float)
signal started_dive
signal started_swoop

@export var stats: PigeonStats
var flap_held: bool = false
var facing: int = 1
var is_gliding: bool = false
var glide_timer: float = 0.0
var is_diving: bool = false
var is_sprinting: bool = false
var sprint_held: bool = false
var sprint_timer: float = 0.0
var sprint_ground_cooldown_timer: float = 0.0
var sprint_air_cooldown_timer: float = 0.0
var sprint_is_air: bool = false
var swoop_timer: float = 0.0
var time_off_floor: float = 0.0

var _coyote_timer: float = 0.0
var _flap_buffer_timer: float = 0.0
var _flap_cut_armed: bool = false
var _was_on_floor: bool = false
var _peak_fall_speed: float = 0.0
var _skill_tree: SkillTree


func _ready() -> void:
	super._ready()
	if stats == null:
		stats = PigeonStats.new()

	_skill_tree = get_node_or_null("SkillTree") as SkillTree


func _physics_process(delta: float) -> void:
	# These timers are maintained independently of the state machine so both
	# player and future AI controllers get identical movement behaviour.
	_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_flap_buffer_timer = maxf(_flap_buffer_timer - delta, 0.0)
	swoop_timer = maxf(swoop_timer - delta, 0.0)
	sprint_ground_cooldown_timer = maxf(sprint_ground_cooldown_timer - delta, 0.0)
	sprint_air_cooldown_timer = maxf(sprint_air_cooldown_timer - delta, 0.0)

	var on_floor := is_on_floor()
	time_off_floor = 0.0 if on_floor else time_off_floor + delta

	if is_sprinting:
		sprint_timer = maxf(sprint_timer - delta, 0.0)
		var ground_sprint_left_floor := not sprint_is_air and time_off_floor > stats.floor_grace_time
		var air_sprint_landed := sprint_is_air and on_floor
		if not sprint_held or sprint_timer <= 0.0 or ground_sprint_left_floor or air_sprint_landed:
			_end_sprint()
		
	if on_floor:
		_coyote_timer = stats.coyote_time
		is_gliding = false
		glide_timer = 0.0

		if not _was_on_floor:
			landed.emit(_peak_fall_speed)
			_peak_fall_speed = 0.0
			# A buffered flap makes landing feel responsive without making the
			# player mash the button on the exact landing frame.
			if _flap_buffer_timer > 0.0:
				_flap_buffer_timer = 0.0
				try_flap()
	else:
		_peak_fall_speed = maxf(_peak_fall_speed, velocity.y)

	# Releasing flap early produces a short hop instead of a full-height flap.
	if _flap_cut_armed and not flap_held and velocity.y < 0.0:
		velocity.y *= stats.flap_release_cut
		_flap_cut_armed = false
	elif velocity.y >= 0.0:
		_flap_cut_armed = false

	_was_on_floor = on_floor

func _end_sprint() -> void:
	if not is_sprinting:
		return
	is_sprinting = false
	if sprint_is_air:
		sprint_air_cooldown_timer = stats.sprint_air_cooldown
	else:
		sprint_ground_cooldown_timer = stats.sprint_ground_cooldown
		
func get_skill_tree() -> SkillTree:
	return _skill_tree


func _effect(effect_id: StringName) -> float:
	if _skill_tree == null:
		return 0.0
	return _skill_tree.get_effect_value(effect_id)


func get_flight_speed() -> float:
	return stats.flight_speed + _effect(&"flight_speed_add")


func get_flap_strength() -> float:
	return stats.flap_strength + _effect(&"flap_strength_add")


func can_dive() -> bool:
	return stats.can_dive or _effect(&"unlock_dive") > 0.0


func can_glide() -> bool:
	return stats.can_glide or _effect(&"unlock_glide") > 0.0


func get_move_speed() -> float:
	return stats.walk_speed


func update_facing() -> void:
	super.update_facing()

	if move_direction.x != 0.0:
		facing = 1 if move_direction.x > 0.0 else -1


func buffer_flap() -> void:
	_flap_buffer_timer = stats.flap_buffer_time


func try_flap() -> bool:
	var from_ground := _coyote_timer > 0.0

	_coyote_timer = 0.0
	flap()
	flapped.emit(from_ground)
	return true


func flap() -> void:
	velocity.y = -get_flap_strength()
	glide_timer = 0.0
	_flap_cut_armed = true
	is_gliding = false
	is_diving = false


func start_sprint() -> bool:
	if is_sprinting:
		return false

	if is_on_floor():
		if sprint_ground_cooldown_timer > 0.0:
			return false
		is_sprinting = true
		sprint_is_air = false
		sprint_timer = get_ground_sprint_duration()
		return true

	if sprint_air_cooldown_timer > 0.0:
		return false

	is_sprinting = true
	sprint_is_air = true
	sprint_timer = get_air_sprint_duration()
	return true

func get_ground_sprint_duration() -> float:
	return maxf(stats.sprint_ground_duration + _effect(&"sprint_ground_duration_add"), 0.1)


func get_air_sprint_duration() -> float:
	return maxf(stats.sprint_air_duration + _effect(&"sprint_air_duration_add"), 0.1)


func get_glide_duration() -> float:
	return maxf(stats.glide_duration + _effect(&"glide_duration_add"), 0.1)


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
	var speed := get_move_speed()
	var acceleration := stats.ground_acceleration
	if is_sprinting and not sprint_is_air:
		speed = stats.sprint_ground_speed
		acceleration = stats.sprint_ground_acceleration

	steer_horizontal(
		speed,
		acceleration,
		stats.ground_friction,
		delta
	)
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y = minf(velocity.y + stats.gravity * delta, stats.max_fall_speed)
	move_and_slide()


func air_move(delta: float) -> void:
	_apply_air_gravity(delta)

	var speed := get_flight_speed()
	var acceleration := stats.air_acceleration
	if is_sprinting and sprint_is_air:
		speed = maxf(speed, stats.sprint_air_speed)
		acceleration = stats.sprint_air_acceleration
	if is_gliding:
		speed *= stats.glide_speed_multiplier

	steer_horizontal(speed, acceleration, stats.air_friction, delta)
	move_and_slide()


func _apply_air_gravity(delta: float) -> void:
	glide_timer = maxf(glide_timer - delta, 0.0)
	if is_diving:
		velocity.y = move_toward(velocity.y, stats.dive_speed, stats.dive_acceleration * delta)
		return

	if is_gliding and glide_timer <= 0.0:
		is_gliding = false
	if not is_gliding and _can_glide_now():
		is_gliding = true
		glide_timer = get_glide_duration()

	if is_gliding:
		# Gliding is always free, including at zero energy.
		velocity.y = move_toward(velocity.y, stats.glide_fall_speed, stats.glide_brake * delta)
		return

	var g := stats.gravity * gravity_scale
	if flap_held and absf(velocity.y) < stats.apex_threshold:
		g *= stats.apex_gravity_multiplier
	elif velocity.y > 0.0:
		g *= stats.fall_gravity_multiplier

	velocity.y = minf(velocity.y + g * delta, stats.max_fall_speed)


func _can_glide_now() -> bool:
	if not flap_held or velocity.y <= 0.0 or not can_glide():
		return false

	return stats.glide_energy_per_second <= 0.0 or current_energy > 0.0


func start_dive() -> bool:
	if not can_dive() or is_on_floor():
		return false

	is_diving = true
	is_gliding = false
	_flap_cut_armed = false
	velocity.x = float(facing) * stats.dive_horizontal_speed
	velocity.y = stats.dive_speed
	started_dive.emit()
	return true


func end_dive() -> void:
	is_diving = false


func begin_swoop() -> void:
	end_dive()
	swoop_timer = stats.swoop_duration
	velocity.x = float(facing) * stats.swoop_speed
	started_swoop.emit()


func is_swooping() -> bool:
	return swoop_timer > 0.0


func swoop_move(delta: float) -> void:
	var input := move_direction.x
	var target_speed := stats.swoop_speed
	if input != 0.0:
		target_speed *= signf(input)
	else:
		target_speed = 0.0

	velocity.x = move_toward(velocity.x, target_speed, stats.ground_acceleration * delta)
	velocity.y = 0.0
	move_and_slide()

func get_sprint_ratio(air: bool) -> float:
	if is_sprinting and sprint_is_air == air:
		var duration := get_air_sprint_duration() if air else get_ground_sprint_duration()
		return sprint_timer / duration

	var cooldown := stats.sprint_air_cooldown if air else stats.sprint_ground_cooldown
	if cooldown <= 0.0:
		return 1.0
	var remaining := sprint_air_cooldown_timer if air else sprint_ground_cooldown_timer
	return 1.0 - remaining / cooldown


func get_sprint_remaining(air: bool) -> float:
	if is_sprinting and sprint_is_air == air:
		return sprint_timer
	return sprint_air_cooldown_timer if air else sprint_ground_cooldown_timer
