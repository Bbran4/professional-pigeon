extends Node
class_name PlayerController

@export var state_machine: StateMachine
@export var drop_through_duration: float = 0.35

var is_dropping_through: bool = false


func _process(_delta: float) -> void:
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

		if Input.is_action_pressed("sprint") and pigeon.is_on_floor():
			if pigeon.start_sprint():
				state_machine.transition(StateMachine.Intent.FALL)
				return

		if Input.is_action_just_pressed("sprint") and not pigeon.is_on_floor():
			if pigeon.start_sprint():
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
				drop_through_platforms()
				return
			elif pigeon.start_dive():
				state_machine.transition(StateMachine.Intent.FALL)
				return

	if player and Input.is_action_just_pressed("collect"):
		player.collect_bread()

	if state_machine.current_state is FlightState:
		return

	if not actor.is_on_floor():
		if not pigeon or not pigeon.is_diving:
			state_machine.transition(StateMachine.Intent.FALL)
	elif horizontal == 0.0:
		state_machine.transition(StateMachine.Intent.IDLE)
	else:
		state_machine.transition(StateMachine.Intent.WALK)


func drop_through_platforms() -> void:
	if is_dropping_through:
		return

	is_dropping_through = true
	state_machine.transition(StateMachine.Intent.FALL)

	for platform in get_tree().get_nodes_in_group("drop_through_platform"):
		var collision_shape := platform as CollisionShape2D
		if collision_shape:
			collision_shape.set_deferred("disabled", true)

	await get_tree().create_timer(drop_through_duration).timeout

	for platform in get_tree().get_nodes_in_group("drop_through_platform"):
		var collision_shape := platform as CollisionShape2D
		if collision_shape:
			collision_shape.set_deferred("disabled", false)

	is_dropping_through = false
