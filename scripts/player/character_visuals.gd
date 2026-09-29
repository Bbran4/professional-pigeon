extends Node2D
class_name CharacterVisuals

## CharacterVisuals owns the visual representation of the player.
## The movement state machine remains responsible for gameplay state.
## This node only translates that state into character animations and layers.
##
## Each visual layer can eventually have its own AnimatedSprite2D:
## - Body
## - Hair
## - Face
## - Clothing
## - Equipment
##
## Artwork is intentionally not required yet. Empty AnimatedSprite2D nodes
## can exist until the first real character sprites are imported.

@onready var player: Player = get_parent().get_parent() as Player
@onready var body: AnimatedSprite2D = $Body
@onready var hair: AnimatedSprite2D = $Hair
@onready var face: AnimatedSprite2D = $Face
@onready var clothing: AnimatedSprite2D = $Clothing
@onready var equipment: AnimatedSprite2D = $Equipment

var current_direction: String = "down"
var current_animation: String = "idle"

func _ready() -> void:
	## Listen to the existing movement state machine instead of creating
	## another state system just for visuals.
	if player == null:
		push_error("CharacterVisuals must be a child of Player/Visuals.")
		return

	player.state_machine.state_changed.connect(_on_state_changed)
	update_direction(player.facing_direction)
	update_animation(player.state_machine.current_state)

func update_direction(direction: Vector2) -> void:
	## Convert the player's four cardinal facing directions into stable
	## animation suffixes used by the sprite assets.
	var direction_name: String = current_direction

	if direction == Vector2.DOWN:
		direction_name = "down"
	elif direction == Vector2.LEFT:
		direction_name = "left"
	elif direction == Vector2.RIGHT:
		direction_name = "right"
	elif direction == Vector2.UP:
		direction_name = "up"

	current_direction = direction_name
	_refresh_current_animation()

func update_animation(state: PlayerState) -> void:
	## Convert the gameplay state name into the animation name used by
	## the modular sprite layers.
	if state == null:
		current_animation = "idle"
		_refresh_current_animation()
		return

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

	_refresh_current_animation()

func _on_state_changed(previous_state: PlayerState, new_state: PlayerState) -> void:
	## A state change is enough to update the animation. Direction is already
	## tracked by Player whenever movement input changes.
	update_animation(new_state)

func _refresh_current_animation() -> void:
	## Animation names follow one convention:
	## idle_down, idle_left, idle_right, idle_up
	## walk_down, walk_left, walk_right, walk_up
	## etc.
	var animation_name: String = current_animation + "_" + current_direction

	_play_layer(body, animation_name)
	_play_layer(hair, animation_name)
	_play_layer(face, animation_name)
	_play_layer(clothing, animation_name)
	_play_layer(equipment, animation_name)

func _play_layer(layer: AnimatedSprite2D, animation_name: String) -> void:
	## Empty AnimatedSprite2D nodes are valid while artwork is being created.
	## Only try to play an animation when that layer has SpriteFrames assigned.
	if layer.sprite_frames == null:
		return

	if not layer.sprite_frames.has_animation(animation_name):
		return

	layer.play(animation_name)
