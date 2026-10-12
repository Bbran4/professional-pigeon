extends Node

## Owns save-file I/O and dirty-state tracking. Game rules stay elsewhere.
const SAVE_PATH := "user://professional_pigeon_save.json"

var _dirty := false


func mark_dirty() -> void:
	_dirty = true


func is_dirty() -> bool:
	return _dirty


func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveService: unable to open save file for reading.")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("SaveService: save file is invalid; using fresh progress.")
		return {}
	return parsed


func save_data(data: Dictionary) -> void:
	if not _dirty:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveService: unable to open save file for writing.")
		return
	file.store_string(JSON.stringify(data, "\\t"))
	_dirty = false


func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		if error != OK:
			push_warning("SaveService: unable to remove save file (error %d)." % error)
	_dirty = false
