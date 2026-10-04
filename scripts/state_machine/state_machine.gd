extends Node
class_name StateMachine

var current_state: State
@export var initial_state: State

enum State {
	IDLE,
	WALK
}

func _ready() -> void:
	if initial_state:
		change_state(initial_state)
	

func _process(delta: float) -> void:
	update_state(delta)

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func update_state(delta: float) -> void:
	if current_state:
		current_state.update(delta)
