extends Node2D

@onready var player: Player = $Player

const BUILDING_COLLISION_PADDING: float = 10.0


func _ready() -> void:
	$Ground.position = Vector2(0, 568)
	$StartingBuilding.position = Vector2(0, 300)
	$BuildingTwo.position = Vector2(650, 388)
	$BuildingThree.position = Vector2(950, 248)
	player.position = Vector2(520, 500)


func _process(_delta: float) -> void:
	update_building_collision($StartingBuilding)
	update_building_collision($BuildingTwo)
	update_building_collision($BuildingThree)


func update_building_collision(building: StaticBody2D) -> void:
	var collision_shape := building.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return

	var player_collision := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if player_collision == null or player_collision.shape == null:
		return

	var building_top := building.global_position.y
	var player_bottom := player.global_position.y + player_collision.shape.get_rect().size.y / 2.0
	var enable_height := building_top - BUILDING_COLLISION_PADDING

	# The roof becomes solid only after the entire pigeon is at least
	# 10 pixels above the building. This prevents the roof from catching
	# the pigeon while it is flying upward.
	collision_shape.disabled = player_bottom > enable_height
