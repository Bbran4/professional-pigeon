extends RefCounted
class_name PerchAllocator

## Owns reservations and fallback landing positions for active visitors.

var park_layout: ParkLayout
var park_node: Node2D
var reserved_perches: Dictionary = {}
var _next_overflow_perch := 0


func configure(layout: ParkLayout, park: Node2D) -> void:
	park_layout = layout
	park_node = park


func reserve_perch(tree: SceneTree) -> PerchReservation:
	if park_layout == null or not is_instance_valid(park_node):
		push_error("PerchAllocator: configure() must be called with a ParkLayout and park node.")
		return null

	var candidates: Array[PerchReservation] = []
	for marker in tree.get_nodes_in_group("perch_spots"):
		if not is_instance_valid(marker) or not marker is Node2D or not marker.is_visible_in_tree():
			continue
		var key := str(marker.get_instance_id())
		if not reserved_perches.has(key):
			candidates.append(PerchReservation.new(key, (marker as Node2D).global_position))
	if not candidates.is_empty():
		var selected: PerchReservation = candidates[randi_range(0, candidates.size() - 1)]
		reserved_perches[selected.key] = true
		return selected

	# Normal landing locations must be placed as Marker2D nodes in the
	# "perch_spots" group. Only overflow visitors use generated positions.

	# Layout never caps visitor capacity: overflow visitors receive virtual spots.
	var overflow_index := _next_overflow_perch
	_next_overflow_perch += 1
	var columns := maxi(1, int(park_layout.visitor_bounds.size.x / 72.0))
	var rows := maxi(1, int(park_layout.visitor_bounds.size.y / 54.0))
	var cell_index := overflow_index % (columns * rows)
	var cell_x := cell_index % columns
	var cell_y := int(cell_index / columns)
	var overflow_position := Vector2(
		park_layout.visitor_bounds.position.x + 36.0 + cell_x * 72.0,
		park_layout.visitor_bounds.position.y + 27.0 + cell_y * 54.0
	)
	var overflow_key := "overflow_%d" % overflow_index
	reserved_perches[overflow_key] = true
	return PerchReservation.new(overflow_key, park_node.to_global(overflow_position))


func release_perch(key: String) -> void:
	reserved_perches.erase(key)


func reset() -> void:
	reserved_perches.clear()
	_next_overflow_perch = 0
