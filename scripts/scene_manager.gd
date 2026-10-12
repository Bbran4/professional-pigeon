extends Node

## Central registry for scene destinations. Callers use stable IDs instead of paths.
const SCENES: Dictionary = {
	&"main_menu": "res://scenes/ui/main_menu.tscn",
	&"park": "res://scenes/game.tscn",
	&"upgrades": "res://scenes/progression/upgrade_screen.tscn",
}


func change_to(scene_id: StringName) -> Error:
	if not SCENES.has(scene_id):
		push_error("SceneManager: Unknown scene ID '%s'." % scene_id)
		return ERR_DOES_NOT_EXIST

	var scene_path: String = SCENES[scene_id]
	if not ResourceLoader.exists(scene_path, "PackedScene"):
		push_error("SceneManager: Scene '%s' does not exist at '%s'." % [scene_id, scene_path])
		return ERR_FILE_NOT_FOUND

	return get_tree().change_scene_to_file(scene_path)
