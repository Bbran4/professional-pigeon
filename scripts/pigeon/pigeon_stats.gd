extends Resource
class_name PigeonStats

## Ground movement
@export var walk_speed: float = 140.0
@export var ground_acceleration: float = 1400.0
@export var ground_friction: float = 1800.0

## Air movement
@export var flight_speed: float = 200.0
@export var air_acceleration: float = 1100.0
@export var air_friction: float = 600.0
@export var turn_multiplier: float = 2.0
@export var overspeed_friction: float = 450.0

## Gravity shaping
@export var gravity: float = 900.0
@export var fall_gravity_multiplier: float = 1.7
@export var apex_gravity_multiplier: float = 0.55
@export var apex_threshold: float = 70.0
@export var max_fall_speed: float = 560.0

## Flap
@export var flap_strength: float = 350.0
@export_range(0.0, 1.0, 0.05) var flap_release_cut: float = 0.45
