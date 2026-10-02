extends Node
class_name Health

## Reusable health component.
## Development targets can use unlimited_health to receive damage without dying.

signal damage_taken(amount: float)
signal health_changed(current_health: float, max_health: float)

@export var max_health: float = 100.0
@export var unlimited_health: bool = false

var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if amount <= 0.0:
		return

	if not unlimited_health:
		current_health = max(current_health - amount, 0.0)

	damage_taken.emit(amount)
	health_changed.emit(current_health, max_health)

func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return not unlimited_health and current_health <= 0.0
