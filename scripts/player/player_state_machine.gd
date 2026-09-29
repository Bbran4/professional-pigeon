extends Node
class_name PlayerStateMachine

## Lightweight state machine for the player controller.
## Movement behaviour lives in Player; this node owns the current movement state.

enum State {
	IDLE,
	WALK,
	RUN,
	DODGE,
	JUMP,
}

signal state_changed(previous_state: State, new_state: State)

var current_state: State = State.IDLE
var previous_state: State = State.IDLE

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	previous_state = current_state
	current_state = new_state
	state_changed.emit(previous_state, current_state)

func is_state(state: State) -> bool:
	return current_state == state
