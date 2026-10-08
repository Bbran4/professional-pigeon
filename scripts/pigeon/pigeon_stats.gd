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
## How strongly the pigeon snaps around when reversing direction.
@export var turn_multiplier: float = 2.0
## Friction applied when carrying more horizontal speed than the flight cap.
@export var overspeed_friction: float = 450.0

## Gravity shaping
@export var gravity: float = 900.0
@export var fall_gravity_multiplier: float = 1.7
## Reduced gravity near the apex while the flap button is held.
@export var apex_gravity_multiplier: float = 0.55
@export var apex_threshold: float = 70.0
@export var max_fall_speed: float = 560.0

## Flap
@export var flap_strength: float = 350.0
## Releasing the flap early cuts the remaining upward velocity.
@export_range(0.0, 1.0, 0.05) var flap_release_cut: float = 0.45
## Small forgiveness window after walking off a ledge.
@export var coyote_time: float = 0.10
@export var floor_grace_time: float = 0.08	
## Small input forgiveness window before landing.
@export var flap_buffer_time: float = 0.12


## Glide
@export var can_glide: bool = true
@export var glide_fall_speed: float = 70.0
@export var glide_brake: float = 1500.0
@export var glide_speed_multiplier: float = 1.2
## Gliding is free. Energy is reserved for active flapping/sprinting.
@export var glide_energy_per_second: float = 0.0
@export var glide_duration: float = 1.0

## Ground sprint / air burst
@export var sprint_ground_speed: float = 300.0
@export var sprint_ground_duration: float = 1.0
@export var sprint_ground_cooldown: float = 5.0
@export var sprint_ground_acceleration: float = 2800.0
@export var sprint_air_duration: float = 1.0
@export var sprint_air_cooldown: float = 10.0
@export var sprint_air_acceleration: float = 2600.0
@export var sprint_air_speed: float = 420.0

## Dive and swoop
@export var can_dive: bool = false
@export var dive_speed: float = 700.0
@export var dive_acceleration: float = 3000.0
@export var dive_horizontal_speed: float = 150.0
@export var swoop_speed: float = 380.0
@export var swoop_duration: float = 0.35

## Other abilities
@export var can_peck: bool = true
