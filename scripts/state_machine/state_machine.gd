extends Node
class_name StateMachine

signal state_changed(previous_state: State, new_state: State)

enum Intent {
	IDLE,
	WALK,
	FALL,
	FLY,
}

@export var initial_state: State

var actor: Actor
var current_state: State
var previous_state: State
var states_by_intent: Dictionary = {}


func _ready() -> void:
	actor = get_parent() as Actor

	if actor == null:
		push_error("StateMachine must be a child of an Actor.")
		return

	for child: Node in get_children():
		var state := child as State
		if state == null:
			continue

		state.state_machine = self
		states_by_intent[state.intent] = state

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
	var state: State = states_by_intent.get(intent)
	if state == null:
		push_error("StateMachine could not find a state for intent: " + str(intent))
		return

	change_state(state)


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	previous_state = current_state

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter(previous_state)

	state_changed.emit(previous_state, current_state)
