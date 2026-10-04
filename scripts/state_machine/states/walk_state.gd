extends State
class_name WalkState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"walk")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	state_machine.actor.move()

	var pigeon := state_machine.actor as Pigeon
	if pigeon:
		pigeon.regenerate_energy(delta)
