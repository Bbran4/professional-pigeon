extends Actor
class_name Pigeon

@export var stats: PigeonStats

var current_energy: float


func _ready() -> void:
	if stats == null:
		stats = PigeonStats.new()

	current_energy = stats.max_energy


func get_move_speed() -> float:
	return stats.walk_speed


func fly() -> void:
	velocity = move_direction * stats.flight_speed
	move_and_slide()


func drain_energy(amount: float) -> void:
	current_energy = maxf(current_energy - amount, 0.0)


func regenerate_energy(delta: float) -> void:
	current_energy = minf(
		current_energy + stats.energy_regeneration * delta,
		stats.max_energy
	)
