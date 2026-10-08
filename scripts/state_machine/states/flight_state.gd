extends State
class_name FlightState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"fly")


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon == null:
		return

	pigeon.move_top_down(pigeon.move_direction, pigeon.stats.flight_speed, delta)
