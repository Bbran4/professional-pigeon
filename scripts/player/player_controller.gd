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

	if player and Input.is_action_just_pressed("collect"):
		player.collect_bread()

	actor.move_direction = Vector2(horizontal, 0.0)
	actor.update_facing()

	if pigeon and Input.is_action_just_pressed("move_down") and actor.is_on_floor():
		drop_through_platforms()
		return

	if pigeon and Input.is_action_just_pressed("move_up") and pigeon.current_energy > 0.0:
		pigeon.drain_energy(1.0)
		state_machine.transition(StateMachine.Intent.FLY)
		pigeon.flap()
		return

	if state_machine.current_state is FlightState:
		return

	if not actor.is_on_floor():
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
