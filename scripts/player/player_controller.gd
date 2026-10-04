extends Node
class_name PlayerController

@export var state_machine: StateMachine


func _process(_delta: float) -> void:
	if state_machine == null:
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	state_machine.actor.move_direction = direction

	if direction == Vector2.ZERO:
		state_machine.transition(StateMachine.Intent.IDLE)
	else:
		state_machine.transition(StateMachine.Intent.WALK)
