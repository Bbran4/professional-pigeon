extends State
class_name IdleState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"idle")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon:
		pigeon.ground_move(delta)
		pigeon.regenerate_energy(delta)
		return

	state_machine.actor.stop()
