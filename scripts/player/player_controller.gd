extends Node
class_name PlayerController

@export var state_machine: StateMachine


func _process(_delta: float) -> void:
	if state_machine == null:
		return

	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		state_machine.transition(StateMachine.Intent.WALK)
	else:
		state_machine.transition(StateMachine.Intent.IDLE)
