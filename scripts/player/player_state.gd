extends Node
class_name PlayerState

## Base class for every Player state.
## A state gets a reference to the Player and the StateMachine so it can
## make decisions and ask the Player to perform shared operations.
##
## Individual states override enter_state(), exit_state(), process_state(),
## and/or physics_process_state() as needed.

var player: Player = null
var state_machine: PlayerStateMachine = null

func setup(player_reference: Player, state_machine_reference: PlayerStateMachine) -> void:
	## The state machine calls setup once for every state when the game starts.
	player = player_reference
	state_machine = state_machine_reference

func enter_state(previous_state: PlayerState) -> void:
	## Called once when this state becomes active.
	pass

func exit_state() -> void:
	## Called once immediately before this state stops being active.
	pass

func process_state(delta: float) -> void:
	## Optional per-frame logic for a state.
	pass

func physics_process_state(delta: float) -> void:
	## Optional physics-frame logic for a state.
	pass
