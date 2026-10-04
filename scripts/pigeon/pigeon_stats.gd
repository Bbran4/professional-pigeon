extends Resource
class_name PigeonStats

## Movement
@export var walk_speed: float = 100.0
@export var flight_speed: float = 200.0
@export var flap_strength: float = 350.0

## Energy
@export var max_energy: float = 3.0
@export var energy_regeneration: float = 10.0

## Abilities
@export var can_dive: bool = false
@export var can_peck: bool = true
