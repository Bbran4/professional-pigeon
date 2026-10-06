extends Pigeon
class_name Player

signal collectible_collected

var nearby_collectible: Collectible

@onready var inventory: PlayerInventory = $Inventory
@onready var _collect_detector: Area2D = $CollectDetector
@onready var _state_machine: StateMachine = $StateMachine
@onready var _controller: PlayerController = $PlayerController


func _process(_delta: float) -> void:
	update_interaction_prompt()


func update_interaction_prompt() -> void:
	var closest := _get_closest_collectible()
	if closest == nearby_collectible:
		return

	if is_instance_valid(nearby_collectible):
		nearby_collectible.set_prompt_visible(false)

	nearby_collectible = closest
	if nearby_collectible:
		nearby_collectible.set_prompt_visible(true)


func _get_closest_collectible() -> Collectible:
	var closest: Collectible
	var closest_distance := INF

	for area: Area2D in _collect_detector.get_overlapping_areas():
		var collectible := area as Collectible
		if collectible == null or collectible.is_queued_for_deletion():
			continue

		var distance := global_position.distance_squared_to(collectible.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = collectible

	return closest


func collect_nearest() -> bool:
	var target := _get_closest_collectible()
	if target == null or target.data == null:
		return false

	var value := target.get_value()
	var skill_tree := get_skill_tree()
	if skill_tree and target.data.value_effect_id != &"":
		value += int(skill_tree.get_effect_value(target.data.value_effect_id))

	if target.get_collectible_type() == CollectibleData.CollectibleType.FOOD:
		inventory.add_food(value)
	else:
		inventory.add_coin(value)

	target.collect()
	nearby_collectible = null
	collectible_collected.emit()
	return true


func set_run_active(active: bool) -> void:
	_state_machine.set_process(active)
	_state_machine.set_physics_process(active)
	_controller.set_physics_process(active)

	if not active:
		stop()
