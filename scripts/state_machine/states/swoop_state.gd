extends State
class_name SwoopState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"walk")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	var pigeon := state_machine.actor as Pigeon
	if pigeon == null:
		transition(StateMachine.Intent.IDLE)
		return

	pigeon.swoop_move(delta)

	if not pigeon.is_on_floor():
		transition(StateMachine.Intent.FALL)
		return

	if not pigeon.is_swooping():
		if pigeon.move_direction.x == 0.0:
			transition(StateMachine.Intent.IDLE)
		else:
			transition(StateMachine.Intent.WALK)
