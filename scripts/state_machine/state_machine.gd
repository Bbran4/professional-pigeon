extends Node
class_name StateMachine

signal state_changed(previous_state: State, new_state: State)

enum Intent {
	IDLE,
	WALK
}

@export var initial_state: State

var current_state: State
var previous_state: State


func _ready() -> void:
	for child: Node in get_children():
		var state := child as State
		if state == null:
			continue
		state.state_machine = self

	if initial_state == null:
		push_error("StateMachine requires an initial state.")
		return

	change_state(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func transition(intent: Intent) -> void:
	for child: Node in get_children():
		var state := child as State
		if state == null:
			continue

		if state.intent == intent:
			change_state(state)
			return

	push_error("StateMachine could not find a state for intent: " + str(intent))


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	previous_state = current_state

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter(previous_state)

	state_changed.emit(previous_state, current_state)
