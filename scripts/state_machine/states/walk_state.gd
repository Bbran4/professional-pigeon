extends State
class_name WalkState


func enter(_previous_state: State) -> void:
	print("Entered State: Walk")


func exit() -> void:
	print("Exited State: Walk")


func physics_update(_delta: float) -> void:
	state_machine.actor.move()
