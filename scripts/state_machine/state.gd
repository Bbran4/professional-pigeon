extends Node
class_name State

var state_machine: StateMachine

func _ready() -> void:
	state_machine = get_parent()

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func transition(intent: StateMachine.State) -> void:
	state_machine.transition(intent)
