extends Node

## Owns save-file I/O, schema migration, validation, and dirty-state tracking.
const SAVE_PATH := "user://professional_pigeon_save.json"
const TEMP_PATH := "user://professional_pigeon_save.json.tmp"
const BACKUP_PATH := "user://professional_pigeon_save.json.bak"
const CURRENT_VERSION := 2

var _dirty := false


func mark_dirty() -> void:
	_dirty = true


func is_dirty() -> bool:
	return _dirty


## Returns validated current-version data. Invalid files are quarantined instead
## of silently overwritten, so the original data can still be recovered.
func load_data() -> Dictionary:
	var loaded := _try_load_path(SAVE_PATH, true)
	if not loaded.is_empty():
		return loaded

	# The primary file may be missing or quarantined as invalid. Try the last
	# known-good save before falling back to a fresh game.
	loaded = _try_load_path(BACKUP_PATH, false)
	if not loaded.is_empty():
		push_warning("SaveService: recovered save data from backup; the next save will repair the primary file.")
		_dirty = true
		return loaded

	return {}


func _try_load_path(path: String, quarantine_invalid: bool) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("SaveService: unable to open %s for reading." % path)
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		if quarantine_invalid:
			_quarantine_invalid_save("invalid_json")
		else:
			push_warning("SaveService: backup save contains invalid JSON.")
		return {}

	var raw: Dictionary = parsed
	var version_value: Variant = raw.get("version", 1)
	if not _is_integer(version_value):
		if quarantine_invalid:
			_quarantine_invalid_save("invalid_version")
		else:
			push_warning("SaveService: backup save has an invalid version.")
		return {}
	var version := int(version_value)

	var migrated: Dictionary
	match version:
		1:
			migrated = _migrate_v1(raw)
		CURRENT_VERSION:
			migrated = _validate_v2(raw)
		_:
			push_warning("SaveService: unsupported save version %d in %s; preserving it." % [version, path])
			return {}

	if migrated.is_empty():
		if quarantine_invalid:
			_quarantine_invalid_save("invalid_data")
		else:
			push_warning("SaveService: backup save failed validation.")
		return {}

	if version != CURRENT_VERSION:
		_dirty = true
	return migrated

func save_data(data: Dictionary) -> bool:
	if not _dirty:
		return true
	var validated := _validate_v2(data)
	if validated.is_empty():
		push_warning("SaveService: refusing to write invalid save data.")
		return false

	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveService: unable to open temporary save file (error %d)." % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(validated, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_warning("SaveService: failed writing temporary save file (error %d)." % write_error)
		_remove_if_exists(TEMP_PATH)
		return false

	var save_absolute := ProjectSettings.globalize_path(SAVE_PATH)
	var temp_absolute := ProjectSettings.globalize_path(TEMP_PATH)
	var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
	var had_previous := FileAccess.file_exists(SAVE_PATH)

	_remove_if_exists(BACKUP_PATH)
	if had_previous:
		var backup_error := DirAccess.rename_absolute(save_absolute, backup_absolute)
		if backup_error != OK:
			push_warning("SaveService: couldn't preserve previous save (error %d); save was not replaced." % backup_error)
			_remove_if_exists(TEMP_PATH)
			return false

	var replace_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
	if replace_error != OK:
		push_warning("SaveService: couldn't replace save file (error %d)." % replace_error)
		if had_previous:
			var restore_error := DirAccess.rename_absolute(backup_absolute, save_absolute)
			if restore_error != OK:
				push_error("SaveService: failed to restore backup save (error %d)." % restore_error)
		_remove_if_exists(TEMP_PATH)
		return false

	_dirty = false
	return true


func clear_save() -> void:
	_remove_if_exists(SAVE_PATH)
	_remove_if_exists(TEMP_PATH)
	_remove_if_exists(BACKUP_PATH)
	_dirty = false


func _migrate_v1(raw: Dictionary) -> Dictionary:
	var points: Variant = raw.get("points", 0)
	var levels: Variant = raw.get("skill_levels", {})
	if not _is_integer(points) or int(points) < 0 or not levels is Dictionary:
		return {}
	return _validate_v2({
		"version": CURRENT_VERSION,
		"balances": {String(CurrencyIds.FEATHERS): int(points)},
		"skill_levels": levels,
	})


func _validate_v2(raw: Dictionary) -> Dictionary:
	var version: Variant = raw.get("version", null)
	var balances: Variant = raw.get("balances", null)
	var levels: Variant = raw.get("skill_levels", null)
	if not _is_integer(version) or int(version) != CURRENT_VERSION:
		return {}
	if not balances is Dictionary or not levels is Dictionary:
		return {}

	var safe_balances: Dictionary = {}
	for currency_id in balances:
		if not (currency_id is String or currency_id is StringName):
			return {}
		var amount: Variant = balances[currency_id]
		if not _is_integer(amount) or int(amount) < 0:
			return {}
		safe_balances[String(currency_id)] = int(amount)

	var safe_levels: Dictionary = {}
	for skill_id in levels:
		if not (skill_id is String or skill_id is StringName):
			return {}
		var level: Variant = levels[skill_id]
		if not _is_integer(level) or int(level) < 0:
			return {}
		safe_levels[String(skill_id)] = int(level)

	return {
		"version": CURRENT_VERSION,
		"balances": safe_balances,
		"skill_levels": safe_levels,
	}


func _is_integer(value: Variant) -> bool:
	return value is int or (value is float and is_finite(value) and floorf(value) == value)


func _quarantine_invalid_save(reason: String) -> void:
	var quarantine_path := "user://professional_pigeon_save.%d.%s.corrupt" % [int(Time.get_unix_time_from_system()), reason]
	var error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(SAVE_PATH),
		ProjectSettings.globalize_path(quarantine_path)
	)
	if error == OK:
		push_warning("SaveService: invalid save quarantined as %s." % quarantine_path)
	else:
		push_warning("SaveService: invalid save detected but couldn't quarantine it (error %d)." % error)


func _remove_if_exists(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if error != OK:
		push_warning("SaveService: couldn't remove %s (error %d)." % [path, error])
