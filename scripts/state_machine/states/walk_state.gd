extends State
class_name WalkState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"walk")


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon == null:
		return

	pigeon.move_top_down(pigeon.move_direction, pigeon.stats.walk_speed, delta)
