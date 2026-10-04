extends State
class_name FlightState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"fly")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon

	if pigeon == null:
		return

	if pigeon.current_energy <= 0.0:
		transition(StateMachine.Intent.IDLE)
		return

	pigeon.fly()
	pigeon.drain_energy(pigeon.stats.flight_energy_drain * delta)
