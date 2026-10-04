extends Node
class_name PlayerController

@export var state_machine: StateMachine


func _process(_delta: float) -> void:
	if state_machine == null:
		return

	var actor := state_machine.actor
	var horizontal := Input.get_axis("move_left", "move_right")
	var pigeon := actor as Pigeon

	actor.move_direction = Vector2(horizontal, 0.0)
	actor.update_facing()

	if pigeon and Input.is_action_just_pressed("move_up") and pigeon.current_energy > 0.0:
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
