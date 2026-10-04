extends Node2D

@onready var player: Player = $Player


func _ready() -> void:
	$Ground.position = Vector2(0, 568)
	$StartingBuilding.position = Vector2(0, 300)
	$BuildingTwo.position = Vector2(650, 388)
	$BuildingThree.position = Vector2(950, 248)
	player.position = Vector2(520, 500)


func _physics_process(_delta: float) -> void:
	update_building_collision($StartingBuilding)
	update_building_collision($BuildingTwo)
	update_building_collision($BuildingThree)


func update_building_collision(building: StaticBody2D) -> void:
	var collision_shape := building.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return

	var building_top := building.global_position.y
	var player_bottom := player.global_position.y + 16.0

	# Buildings are only solid from their roof upward.
	# This lets the pigeon walk through the building from the street,
	# then land on the roof when flying down onto it.
	collision_shape.disabled = player_bottom < building_top
