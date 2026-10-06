extends State
class_name FlightState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"fly")


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon == null:
		return

	pigeon.air_move(delta)

	# FlightState owns the rising/apex portion of a flap. Once the pigeon is
	# descending, FallingState takes over so dive/glide behaviour stays explicit.
	if pigeon.is_on_floor():
		transition(StateMachine.Intent.IDLE)
	elif pigeon.velocity.y >= 0.0:
		transition(StateMachine.Intent.FALL)
