extends Pigeon
class_name Player

signal collectible_collected

var nearby_collectible: Collectible

@onready var inventory: PlayerInventory = $Inventory


func _process(_delta: float) -> void:
	update_interaction_prompt()


func update_interaction_prompt() -> void:
	var detector := get_node_or_null("BreadDetector") as Area2D
	var closest_collectible: Collectible
	var closest_distance := INF

	if detector:
		for area: Area2D in detector.get_overlapping_areas():
			var collectible := area as Collectible
			if collectible == null:
				continue

			var distance := global_position.distance_squared_to(collectible.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_collectible = collectible

	if nearby_collectible and is_instance_valid(nearby_collectible):
		nearby_collectible.set_prompt_visible(false)

	nearby_collectible = closest_collectible
	if nearby_collectible:
		nearby_collectible.set_prompt_visible(true)


func collect_bread() -> bool:
	var detector := get_node_or_null("BreadDetector") as Area2D
	if detector == null:
		return false

	var closest_collectible: Collectible
	var closest_distance := INF

	for area: Area2D in detector.get_overlapping_areas():
		var collectible := area as Collectible
		if collectible == null:
			continue

		var distance := global_position.distance_squared_to(collectible.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_collectible = collectible

	if closest_collectible == null or closest_collectible.data == null:
		return false

	var value := closest_collectible.get_value()
	var skill_tree := get_skill_tree()

	if closest_collectible.get_collectible_type() == CollectibleData.CollectibleType.FOOD:
		if closest_collectible.data.id == &"bread" and skill_tree:
			value += int(skill_tree.get_effect_value(&"bread_value_add"))
		inventory.add_food(value)
	else:
		inventory.add_coin(value)

	closest_collectible.collect()
	collectible_collected.emit()
	return true


func set_run_active(active: bool) -> void:
	var state_machine := get_node_or_null("StateMachine")
	var controller := get_node_or_null("PlayerController")

	if state_machine:
		state_machine.set_process(active)
		state_machine.set_physics_process(active)

	if controller:
		controller.set_process(active)

	if not active:
		stop()
