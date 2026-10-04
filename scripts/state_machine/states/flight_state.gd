extends State
class_name FlightState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"fly")

	var pigeon := state_machine.actor as Pigeon
	if pigeon:
		pigeon.show_energy_indicator()


func exit() -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon:
		pigeon.hide_energy_indicator()


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon

	if pigeon == null:
		return

	if pigeon.current_energy <= 0.0:
		transition(StateMachine.Intent.FALL)
		return

	pigeon.apply_gravity(delta)
	pigeon.velocity.x = pigeon.move_direction.x * pigeon.get_flight_speed()
	pigeon.move_and_slide()
	pigeon.drain_energy(pigeon.stats.flight_energy_drain * delta)

	if pigeon.is_on_floor():
		transition(StateMachine.Intent.IDLE)
