extends Pigeon
class_name Player

var bread_count: int = 0


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

	bread_count += 1
	closest_bread.collect()
	return true
