extends State
class_name IdleState

func enter(previous_state: State) -> void:
	print("Entered State: Idle")


func exit() -> void:
	print("Exited State: Idle")
