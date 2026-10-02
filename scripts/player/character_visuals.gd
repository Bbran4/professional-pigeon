extends Node2D
class_name CharacterVisuals

## CharacterVisuals owns the player's sprite-sheet based visual.
## Gameplay states remain responsible for movement. This node only translates
## gameplay state + facing direction into an AnimatedSprite2D animation.

@onready var player: Player = get_parent().get_parent() as Player
@onready var state_machine: PlayerStateMachine = $"../../StateMachine"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_direction: String = "down"
var current_animation: String = "idle"

func _ready() -> void:
	if player == null:
		push_error("CharacterVisuals must be a child of Player/Visuals.")
		return

	if state_machine == null:
		push_error("CharacterVisuals could not find Player/StateMachine.")
		return

	state_machine.state_changed.connect(_on_state_changed)
	update_direction(player.facing_direction)
	update_animation(state_machine.current_state)

func update_direction(direction: Vector2) -> void:
	if direction == Vector2.DOWN:
		current_direction = "down"
	elif direction == Vector2.LEFT:
		current_direction = "left"
	elif direction == Vector2.RIGHT:
		current_direction = "right"
	elif direction == Vector2.UP:
		current_direction = "up"

	_refresh_animation()

func update_animation(state: PlayerState) -> void:
	if state == null:
		current_animation = "idle"
	else:
		match state.name:
			"Idle":
				current_animation = "idle"
			"Walk":
				current_animation = "walk"
			"Run":
				current_animation = "run"
			"Dodge":
				current_animation = "dodge"
			"Jump":
				current_animation = "jump"
			_:
				current_animation = "idle"

	_refresh_animation()

func _on_state_changed(previous_state: PlayerState, new_state: PlayerState) -> void:
	update_animation(new_state)

func _refresh_animation() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	var animation_name := current_animation + "_" + current_direction

	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
