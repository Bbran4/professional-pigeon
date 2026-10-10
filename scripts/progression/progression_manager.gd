extends Node

signal points_changed(points: int)
signal coin_changed(coin: int)
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var points: int = 0
var coin: int = 0
var skill_levels: Dictionary = {}
var _effect_totals: Dictionary = {}
var _loading_save := false
var _save_dirty := false

const SAVE_PATH := "user://professional_pigeon_save.json"


func _ready() -> void:
	load_game()


func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_F3:
			add_points(1000)
			get_viewport().set_input_as_handled()


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	points += amount
	points_changed.emit(points)
	_mark_save_dirty()


func add_coin(amount: int) -> void:
	if amount <= 0:
		return
	coin += amount
	coin_changed.emit(coin)
	_mark_save_dirty()


func can_spend_points(amount: int) -> bool:
	return amount >= 0 and points >= amount


func can_spend_coin(amount: int) -> bool:
	return amount >= 0 and coin >= amount


func can_spend(points_amount: int, coin_amount: int) -> bool:
	return can_spend_points(points_amount) and can_spend_coin(coin_amount)


func spend_points(amount: int) -> bool:
	if not can_spend_points(amount):
		return false
	points -= amount
	points_changed.emit(points)
	_mark_save_dirty()
	return true


func spend_coin(amount: int) -> bool:
	if not can_spend_coin(amount):
		return false
	coin -= amount
	coin_changed.emit(coin)
	_mark_save_dirty()
	return true


func spend(points_amount: int, coin_amount: int) -> bool:
	if not can_spend(points_amount, coin_amount):
		return false
	points -= points_amount
	coin -= coin_amount
	points_changed.emit(points)
	coin_changed.emit(coin)
	_mark_save_dirty()
	return true


func get_skill_level(skill_id: StringName) -> int:
	return int(skill_levels.get(skill_id, 0))


func set_skill_level(skill_id: StringName, level: int) -> void:
	var safe_level := maxi(level, 0)
	skill_levels[skill_id] = safe_level
	_rebuild_effect_totals()
	skill_level_changed.emit(skill_id, safe_level)
	_mark_save_dirty()


func get_effect_value(effect_id: StringName) -> float:
	return float(_effect_totals.get(effect_id, 0.0))


func _rebuild_effect_totals() -> void:
	_effect_totals.clear()
	for skill in SKILL_CATALOG.skills:
		if skill == null or skill.effect_id == &"":
			continue
		var level := get_skill_level(skill.id)
		if level <= 0:
			continue
		var current_total := float(_effect_totals.get(skill.effect_id, 0.0))
		_effect_totals[skill.effect_id] = current_total + skill.effect_value * level


func reset_save() -> void:
	points = 0
	coin = 0
	skill_levels.clear()
	_effect_totals.clear()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	points_changed.emit(points)
	coin_changed.emit(coin)
	for skill in SKILL_CATALOG.skills:
		if skill != null:
			skill_level_changed.emit(skill.id, 0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_game()


func _mark_save_dirty() -> void:
	if _loading_save:
		return
	_save_dirty = true


func save_game() -> void:
	if not _save_dirty:
		return
	var saved_levels: Dictionary = {}
	for skill_id in skill_levels:
		saved_levels[String(skill_id)] = int(skill_levels[skill_id])
	var save_data := {
		"version": 1,
		"points": points,
		"coin": coin,
		"skill_levels": saved_levels,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("ProgressionManager: unable to open save file for writing.")
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	_save_dirty = false


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("ProgressionManager: unable to open save file for reading.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("ProgressionManager: save file is invalid; using fresh progress.")
		return
	var save_data: Dictionary = parsed
	_loading_save = true
	points = maxi(int(save_data.get("points", 0)), 0)
	coin = maxi(int(save_data.get("coin", 0)), 0)
	skill_levels.clear()
	var saved_levels: Variant = save_data.get("skill_levels", {})
	if saved_levels is Dictionary:
		for skill_id in saved_levels:
			skill_levels[StringName(str(skill_id))] = maxi(int(saved_levels[skill_id]), 0)
	_loading_save = false
	_rebuild_effect_totals()
	points_changed.emit(points)
	coin_changed.emit(coin)
	for skill_id in skill_levels:
		skill_level_changed.emit(skill_id, int(skill_levels[skill_id]))


