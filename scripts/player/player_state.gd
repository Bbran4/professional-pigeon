extends Node
class_name PlayerState

var player: Player = null
var state_machine: PlayerStateMachine = null

func setup(player_reference: Player, state_machine_reference: PlayerStateMachine) -> void:
	player = player_reference
	state_machine = state_machine_reference

func enter_state(previous_state: PlayerState) -> void:
	pass

func exit_state() -> void:
	pass

func process_state(delta: float) -> void:
	pass

func physics_process_state(delta: float) -> void:
	pass
