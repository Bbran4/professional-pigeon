extends Node2D

const WORLD_WIDTH := 6000.0
const GROUND_TOP := 568.0

@onready var player: Player = $Player


func _ready() -> void:
	$Ground.position = Vector2(0, GROUND_TOP)
	$Ground/Visual.polygon = PackedVector2Array([
		Vector2.ZERO, Vector2(WORLD_WIDTH, 0),
		Vector2(WORLD_WIDTH, 80), Vector2(0, 80)
	])
	var ground_shape := $Ground/CollisionShape2D.shape as RectangleShape2D
	ground_shape.size = Vector2(WORLD_WIDTH, 80)
	$Ground/CollisionShape2D.position = Vector2(WORLD_WIDTH * 0.5, 40)

	$FarmHouse.position = Vector2(0, 309)
	$BuildingTwo.position = Vector2(650, 388)
	$BuildingThree.position = Vector2(950, 248)
	player.position = Vector2(270, 290)

	_build_village()


func _build_village() -> void:
	var building_specs := [
		[1450.0, 230.0, 310.0, Color("#9b745e")],
		[1840.0, 300.0, 250.0, Color("#71839a")],
		[2200.0, 190.0, 360.0, Color("#aa8b55")],
		[2660.0, 270.0, 280.0, Color("#98727c")],
		[3050.0, 340.0, 220.0, Color("#718b70")],
		[3440.0, 210.0, 350.0, Color("#a77d5d")],
		[3900.0, 290.0, 270.0, Color("#777e9b")],
		[4300.0, 180.0, 380.0, Color("#b18e60")],
		[4780.0, 320.0, 240.0, Color("#92717d")],
		[5200.0, 250.0, 310.0, Color("#728a83")]
	]

	for index in range(building_specs.size()):
		var spec: Array = building_specs[index]
		_create_building(index, spec[0], spec[1], spec[2], spec[3])


func _create_building(index: int, x: float, width: float, height: float, color: Color) -> void:
	var building := StaticBody2D.new()
	building.name = "VillageBuilding%02d" % index
	building.position = Vector2(x, GROUND_TOP - height)
	building.z_index = -1
	add_child(building)

	var wall := Polygon2D.new()
	wall.color = color
	wall.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(width, 0),
		Vector2(width, height), Vector2(0, height)
	])
	building.add_child(wall)

	var roof := Polygon2D.new()
	roof.color = color.darkened(0.28)
	roof.polygon = PackedVector2Array([
		Vector2(-12, 0), Vector2(width * 0.5, -38),
		Vector2(width + 12, 0)
	])
	building.add_child(roof)

	var roof_collision := CollisionShape2D.new()
	var roof_shape := RectangleShape2D.new()
	roof_shape.size = Vector2(width, 10)
	roof_collision.shape = roof_shape
	roof_collision.position = Vector2(width * 0.5, 5)
	roof_collision.one_way_collision = true
	building.add_child(roof_collision)

	for window_index in range(int(width / 90.0)):
		var window := Polygon2D.new()
		window.color = Color("#e5c78c")
		var window_x := 35.0 + window_index * 90.0
		window.polygon = PackedVector2Array([
			Vector2.ZERO, Vector2(28, 0), Vector2(28, 38), Vector2(0, 38)
		])
		window.position = Vector2(window_x, minf(height - 65.0, 55.0 + float(index % 2) * 25.0))
		building.add_child(window)
