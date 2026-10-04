extends Node
class_name PlayerController

@export var state_machine: StateMachine


func _process(_delta: float) -> void:
	if state_machine == null:
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	state_machine.actor.move_direction = direction

	var wants_to_fly := Input.is_action_pressed("ui_accept")
	var pigeon := state_machine.actor as Pigeon

	if wants_to_fly and direction != Vector2.ZERO and pigeon and pigeon.current_energy > 0.0:
		state_machine.transition(StateMachine.Intent.FLY)
	elif direction == Vector2.ZERO:
		state_machine.transition(StateMachine.Intent.IDLE)
	else:
		state_machine.transition(StateMachine.Intent.WALK)
