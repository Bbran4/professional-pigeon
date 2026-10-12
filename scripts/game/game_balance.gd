extends Resource
class_name GameBalance

## Shared tuning values for visitor behaviour, food bonuses, timing, movement, and spawn limits.

@export_group("Day")
@export_range(1.0, 600.0, 1.0) var default_day_duration: float = 60.0
@export_range(0.0, 5.0, 0.05) var default_arrival_interval: float = 0.25

@export_group("Visitor Movement")
@export var food_distance: float = 28.0
@export var arrival_distance: float = 18.0
@export var departure_distance: float = 40.0
@export var food_search_interval: float = 0.25

@export_group("Food")
@export_range(0.0, 1.0, 0.01) var worm_chance: float = 0.2
@export var worm_chance_per_upgrade: float = 0.05
@export var golden_seed_bonus_points: int = 1
@export var worm_bonus_points: int = 1
@export var unlocked_worm_bonus_points: int = 2
@export var worm_extra_eating_duration: float = 1.5
@export var rare_visitor_bonus_points: int = 2
@export var golden_feather_bonus_points: int = 3

@export_group("Visitor Timing")
@export var visitor_retry_interval: float = 0.5
@export var minimum_spawn_delay: float = 0.1
@export var fountain_spawn_delay_reduction: float = 0.2
@export var minimum_patience_timeout: float = 1.0
@export var minimum_eating_duration: float = 0.25
@export var minimum_dropping_duration: float = 0.25
@export var default_eating_duration: float = 1.0
@export var default_dropping_duration: float = 0.75
@export var default_patience_timeout: float = 3.0

@export_group("Collectible Drops")
@export var feather_drop_offset_x: float = 18.0
@export var feather_drop_offset_y: float = 4.0
@export var extra_feather_offset_x: float = 24.0
@export var extra_feather_offset_y: float = 12.0

@export_group("Flock Limits")
@export_range(1, 100, 1) var minimum_pigeons: int = 1
@export var tree_nest_pigeon_capacity: int = 1
