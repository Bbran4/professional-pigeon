extends Node
class_name PlayerStateMachine

## The PlayerStateMachine owns the currently active PlayerState.
## States are child nodes of this node in the Player scene.
##
## To add a new state later, create another PlayerState script, add it as a
## child of StateMachine, and transition to it by its node name.

signal state_changed(previous_state: PlayerState, new_state: PlayerState)

@export var initial_state: PlayerState

var current_state: PlayerState = null
var previous_state: PlayerState = null
var player: Player = null

func _ready() -> void:
	## StateMachine expects to be a direct child of Player.
	player = get_parent() as Player

	if player == null:
		push_error("PlayerStateMachine must be a child of Player.")
		return

	## Give every state access to the Player and this state machine.
	for child: Node in get_children():
		var state: PlayerState = child as PlayerState
		if state == null:
			continue

		state.setup(player, self)

	## The scene normally supplies Initial State, but falling back to the
	## Idle node makes the machine a little safer to configure.
	if initial_state == null:
		initial_state = get_node_or_null("Idle") as PlayerState

	if initial_state == null:
		push_error("PlayerStateMachine requires an initial state.")
		return

	## Enter the first state.
	transition_to_state(initial_state)

func _process(delta: float) -> void:
	## Forward normal frame processing to whichever state is active.
	if current_state != null:
		current_state.process_state(delta)

func _physics_process(delta: float) -> void:
	## Forward physics processing to whichever state is active.
	if current_state != null:
		current_state.physics_process_state(delta)

func transition_to(state_name: StringName) -> void:
	## Change state using the name of a child node, for example "Walk".
	var next_state: PlayerState = get_node_or_null(NodePath(String(state_name))) as PlayerState

	if next_state == null:
		push_error("PlayerStateMachine could not find state: " + String(state_name))
		return

	transition_to_state(next_state)

func transition_to_state(next_state: PlayerState) -> void:
	## This is the central state transition function.
	## It exits the old state, changes the active state, enters the new state,
	## and finally tells listeners that the state changed.
	if current_state == next_state:
		return

	var previous_state: PlayerState = current_state

	if current_state != null:
		current_state.exit_state()

	previous_state = current_state
	current_state = next_state
	current_state.enter_state(previous_state)
	state_changed.emit(previous_state, current_state)

func is_current_state(state_name: StringName) -> bool:
	## Convenience function for checking the current state by node name.
	if current_state == null:
		return false

	return current_state.name == String(state_name)
