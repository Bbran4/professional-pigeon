extends State
class_name IdleState


func enter(_previous_state: State) -> void:
	print("Entered State: Idle")


func exit() -> void:
	print("Exited State: Idle")


func physics_update(_delta: float) -> void:
	state_machine.actor.stop()
