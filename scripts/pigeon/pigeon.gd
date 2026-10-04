extends Actor
class_name Pigeon

@export var stats: PigeonStats

var current_energy: float

@onready var energy_indicator: EnergyIndicator = $EnergyIndicator


func _ready() -> void:
	if stats == null:
		stats = PigeonStats.new()

	current_energy = get_max_energy()


func get_skill_tree() -> SkillTree:
	return get_node_or_null("SkillTree") as SkillTree


func get_max_energy() -> float:
	var skill_tree := get_skill_tree()
	if skill_tree == null:
		return stats.max_energy

	return stats.max_energy + skill_tree.get_effect_value(&"max_energy_add")


func get_flight_speed() -> float:
	var skill_tree := get_skill_tree()
	if skill_tree == null:
		return stats.flight_speed

	return stats.flight_speed + skill_tree.get_effect_value(&"flight_speed_add")


func get_flap_strength() -> float:
	var skill_tree := get_skill_tree()
	if skill_tree == null:
		return stats.flap_strength

	return stats.flap_strength + skill_tree.get_effect_value(&"flap_strength_add")


func show_energy_indicator() -> void:
	if energy_indicator == null:
		return

	energy_indicator.reset_color()
	energy_indicator.visible = true


func hide_energy_indicator() -> void:
	if energy_indicator == null:
		return

	energy_indicator.visible = false


func get_move_speed() -> float:
	return stats.walk_speed


func flap() -> void:
	velocity.y = -get_flap_strength()


func fly() -> void:
	velocity.x = move_direction.x * get_flight_speed()
	move_and_slide()


func drain_energy(amount: float) -> void:
	current_energy = maxf(current_energy - amount, 0.0)


func regenerate_energy(delta: float) -> void:
	if not is_on_floor():
		return

	current_energy = minf(
		current_energy + stats.energy_regeneration * delta,
		get_max_energy()
	)
