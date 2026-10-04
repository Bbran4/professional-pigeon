extends Node
class_name State

var state_machine: StateMachine
@export var intent: StateMachine.Intent


func enter(previous_state: State) -> void:
	pass


func exit() -> void:
	pass


func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	pass


func transition(intent_to_request: StateMachine.Intent) -> void:
	state_machine.transition(intent_to_request)
