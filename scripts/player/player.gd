extends Pigeon
class_name Player

signal bread_collected

var nearby_bread: Bread

@onready var inventory: PlayerInventory = $Inventory


func _process(_delta: float) -> void:
	update_interaction_prompt()


func update_interaction_prompt() -> void:
	var detector := get_node_or_null("BreadDetector") as Area2D
	var closest_bread: Bread
	var closest_distance := INF

	if detector:
		for area: Area2D in detector.get_overlapping_areas():
			var bread := area as Bread
			if bread == null:
				continue

			var distance := global_position.distance_squared_to(bread.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_bread = bread

	if nearby_bread and is_instance_valid(nearby_bread):
		nearby_bread.set_prompt_visible(false)

	nearby_bread = closest_bread
	if nearby_bread:
		nearby_bread.set_prompt_visible(true)


func collect_bread() -> bool:
	var detector := get_node_or_null("BreadDetector") as Area2D
	if detector == null:
		return false

	var closest_bread: Bread
	var closest_distance := INF

	for area: Area2D in detector.get_overlapping_areas():
		var bread := area as Bread
		if bread == null:
			continue

		var distance := global_position.distance_squared_to(bread.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_bread = bread

	if closest_bread == null:
		return false

	inventory.add_food(1)
	closest_bread.collect()
	bread_collected.emit()
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
