extends State
class_name FallingState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"fly")


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon == null:
		return

	pigeon.air_move(delta)

	if pigeon.is_on_floor():
		transition(StateMachine.Intent.IDLE)
