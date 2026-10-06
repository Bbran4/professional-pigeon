extends Node
class_name PlayerController

@export var state_machine: StateMachine
@export var drop_through_duration: float = 0.35

var is_dropping_through: bool = false

func _ready() -> void:
	# Run before the StateMachine so input is applied in the same physics frame.
	process_physics_priority = -1

func _physics_process(_delta: float) -> void:
	if state_machine == null:
		return

	var actor := state_machine.actor
	var horizontal := Input.get_axis("move_left", "move_right")
	var pigeon := actor as Pigeon
	var player := actor as Player

	actor.move_direction = Vector2(horizontal, 0.0)
	actor.update_facing()

	if pigeon:
		pigeon.flap_held = Input.is_action_pressed("move_up")
		pigeon.sprint_held = Input.is_action_pressed("sprint")

		if pigeon.sprint_held and not pigeon.is_sprinting:
			if pigeon.start_sprint() and not pigeon.is_on_floor():
				state_machine.transition(StateMachine.Intent.FALL)
				return

		if Input.is_action_just_pressed("move_up"):
			if pigeon.is_on_floor() or state_machine.current_state is FallingState:
				pigeon.buffer_flap()
			if pigeon.try_flap():
				state_machine.transition(StateMachine.Intent.FLY)
				return

		if Input.is_action_just_pressed("move_down"):
			if pigeon.is_on_floor():
				if _is_standing_on_drop_through(pigeon):
					drop_through_platforms()
				return
			elif pigeon.start_dive():
				state_machine.transition(StateMachine.Intent.FALL)
				return

	if player and Input.is_action_just_pressed("collect"):
		player.collect_nearest()

	if state_machine.current_state is FlightState:
		return

	if not actor.is_on_floor():
		if pigeon and pigeon.is_diving:
			return

		var in_ground_state := state_machine.current_state is IdleState \
			or state_machine.current_state is WalkState
		if pigeon and in_ground_state and pigeon.time_off_floor < pigeon.stats.floor_grace_time:
			return # brief floor loss on a slope, stay in the ground state

		state_machine.transition(StateMachine.Intent.FALL)
	elif horizontal == 0.0:
		state_machine.transition(StateMachine.Intent.IDLE)
	else:
		state_machine.transition(StateMachine.Intent.WALK)

func _is_standing_on_drop_through(pigeon: Pigeon) -> bool:
	for i in range(pigeon.get_slide_collision_count()):
		var collision := pigeon.get_slide_collision(i)
		var body := collision.get_collider() as CollisionObject2D
		if body == null:
			continue

		var owner_id := body.shape_find_owner(collision.get_collider_shape_index())
		var shape_node := body.shape_owner_get_owner(owner_id)
		if shape_node and shape_node.is_in_group("drop_through_platform"):
			return true

	return false

func drop_through_platforms() -> void:
	if is_dropping_through:
		return

	is_dropping_through = true
	state_machine.transition(StateMachine.Intent.FALL)

	_set_platforms_disabled(true)

	await get_tree().create_timer(drop_through_duration).timeout

	_set_platforms_disabled(false)

	is_dropping_through = false


func _set_platforms_disabled(value: bool) -> void:
	for platform in get_tree().get_nodes_in_group("drop_through_platform"):
		if platform is CollisionShape2D or platform is CollisionPolygon2D:
			platform.set_deferred("disabled", value)
