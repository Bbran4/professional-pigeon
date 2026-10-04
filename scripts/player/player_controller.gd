extends Node
class_name PlayerController

@export var state_machine: StateMachine


func _process(_delta: float) -> void:
	if state_machine == null:
		return

	var actor := state_machine.actor
	var horizontal := Input.get_axis("ui_left", "ui_right")
	var vertical := Input.get_axis("ui_up", "ui_down")
	var pigeon := actor as Pigeon

	actor.move_direction = Vector2(horizontal, vertical)

	var is_flying := state_machine.current_state is FlightState
	var wants_to_start_flying := Input.is_action_pressed("ui_up")

	if pigeon and pigeon.current_energy > 0.0 and (wants_to_start_flying or is_flying):
		state_machine.transition(StateMachine.Intent.FLY)
	elif not actor.is_on_floor():
		state_machine.transition(StateMachine.Intent.FALL)
	elif horizontal == 0.0:
		state_machine.transition(StateMachine.Intent.IDLE)
	else:
		state_machine.transition(StateMachine.Intent.WALK)
