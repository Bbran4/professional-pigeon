extends Node
class_name FeederSpawner

const BREAD_FEEDER_SCENE: PackedScene = preload("res://scenes/park/bread_feeder.tscn")
const SEED_FEEDER_SCENE: PackedScene = preload("res://scenes/park/seed_feeder.tscn")

var _bread_feeders: Array[SeedFeeder] = []
var _seed_feeders: Array[SeedFeeder] = []
var _bread_markers: Array[Marker2D] = []
var _seed_markers: Array[Marker2D] = []


func _ready() -> void:
	_bread_markers = _get_markers(&"bread_feeder_spawn")
	_seed_markers = _get_markers(&"seed_feeder_spawn")
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	call_deferred("_refresh_feeders")


func _get_markers(group_name: StringName) -> Array[Marker2D]:
	var markers: Array[Marker2D] = []
	for node in get_tree().get_nodes_in_group(group_name):
		var marker := node as Marker2D
		if marker != null and marker.is_inside_tree() and marker.is_visible_in_tree():
			markers.append(marker)
	return markers


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	_refresh_feeders()


func _refresh_feeders() -> void:
	if not is_inside_tree():
		return
	var bread_count := 0
	if ProgressionManager.get_skill_level(&"bread") > 0:
		bread_count = 1
	for skill_id in [&"bread_feeder_2", &"bread_feeder_3", &"bread_feeder_4"]:
		if ProgressionManager.get_skill_level(skill_id) > 0:
			bread_count += 1

	var seed_count := 0
	if ProgressionManager.get_skill_level(&"unlock_seeds") > 0:
		seed_count = 1
	for skill_id in [&"more_benches_1", &"more_benches_2", &"more_benches_3"]:
		if ProgressionManager.get_skill_level(skill_id) > 0:
			seed_count += 1

	_sync_feeders(_bread_feeders, bread_count, _bread_markers, BREAD_FEEDER_SCENE)
	_sync_feeders(_seed_feeders, seed_count, _seed_markers, SEED_FEEDER_SCENE)


func _sync_feeders(
	feeders: Array[SeedFeeder],
	desired_count: int,
	markers: Array[Marker2D],
	feeder_scene: PackedScene
) -> void:
	var target_count := mini(desired_count, markers.size())
	while feeders.size() > target_count:
		var feeder := feeders.pop_back()
		if is_instance_valid(feeder):
			feeder.queue_free()

	while feeders.size() < target_count:
		var marker := markers[feeders.size()]
		if not is_instance_valid(marker):
			break
		var feeder := feeder_scene.instantiate() as SeedFeeder
		if feeder == null:
			push_error("FeederSpawner: feeder scene root must extend SeedFeeder.")
			return
		get_parent().add_child(feeder)
		feeder.global_position = marker.global_position
		feeders.append(feeder)
