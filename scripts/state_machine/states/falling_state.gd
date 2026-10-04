extends State
class_name FallingState


func enter(_previous_state: State) -> void:
	state_machine.actor.play_animation(&"fly")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	var actor := state_machine.actor
	actor.apply_gravity(delta)

	actor.velocity.x = actor.move_direction.x * actor.get_move_speed()
	actor.move_and_slide()

	if actor.is_on_floor():
		transition(StateMachine.Intent.IDLE)
