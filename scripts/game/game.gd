extends Node2D


func _ready() -> void:
	$Ground.position = Vector2(0, 568)
	$StartingBuilding.position = Vector2(0, 300)
	$BuildingTwo.position = Vector2(650, 388)
	$BuildingThree.position = Vector2(950, 248)
	$Player.position = Vector2(210, 285)
