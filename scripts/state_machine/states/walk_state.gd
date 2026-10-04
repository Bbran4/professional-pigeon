extends State
class_name WalkState

func enter(previous_state: State) -> void:
	print("Entered State: Walk")


func exit() -> void:
	print("Exited State: Walk")
