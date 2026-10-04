extends Actor
class_name Pigeon

@export var stats: PigeonStats

var current_energy: float
var _energy_regeneration_timer: float = 0.0

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


func get_energy_regeneration_interval() -> float:
	var skill_tree := get_skill_tree()
	if skill_tree == null:
		return maxf(stats.energy_regeneration_interval, 0.1)

	return maxf(
		stats.energy_regeneration_interval
			+ skill_tree.get_effect_value(&"energy_regen_interval_add"),
		0.1
	)


func get_energy_regeneration_amount() -> float:
	var skill_tree := get_skill_tree()
	if skill_tree == null:
		return stats.energy_regeneration_amount

	return stats.energy_regeneration_amount + skill_tree.get_effect_value(&"energy_regen_amount_add")


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
		_energy_regeneration_timer = 0.0
		return

	if current_energy >= get_max_energy():
		_energy_regeneration_timer = 0.0
		return

	_energy_regeneration_timer += delta
	var interval := get_energy_regeneration_interval()

	while _energy_regeneration_timer >= interval:
		_energy_regeneration_timer -= interval
		current_energy = minf(
			current_energy + get_energy_regeneration_amount(),
			get_max_energy()
		)

		if current_energy >= get_max_energy():
			_energy_regeneration_timer = 0.0
			break
