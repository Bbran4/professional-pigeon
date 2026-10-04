extends State
class_name IdleState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"idle")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	state_machine.actor.stop()

	var pigeon := state_machine.actor as Pigeon
	if pigeon:
		pigeon.regenerate_energy(delta)
