extends Node

signal points_changed(points: int)
signal coin_changed(coin: int)
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var points: int = 0
var coin: int = 0
var skill_levels: Dictionary = {}
var _loading_save := false

const SAVE_PATH := "user://professional_pigeon_save.json"


func _ready() -> void:
	load_game()


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	points += amount
	points_changed.emit(points)
	_save_if_ready()


func add_coin(amount: int) -> void:
	if amount <= 0:
		return
	coin += amount
	coin_changed.emit(coin)
	_save_if_ready()


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
	_save_if_ready()
	return true


func spend_coin(amount: int) -> bool:
	if not can_spend_coin(amount):
		return false
	coin -= amount
	coin_changed.emit(coin)
	_save_if_ready()
	return true


func spend(points_amount: int, coin_amount: int) -> bool:
	if not can_spend(points_amount, coin_amount):
		return false
	points -= points_amount
	coin -= coin_amount
	points_changed.emit(points)
	coin_changed.emit(coin)
	_save_if_ready()
	return true


func get_skill_level(skill_id: StringName) -> int:
	return int(skill_levels.get(skill_id, 0))


func set_skill_level(skill_id: StringName, level: int) -> void:
	skill_levels[skill_id] = maxi(level, 0)
	skill_level_changed.emit(skill_id, maxi(level, 0))
	_save_if_ready()


func get_effect_value(effect_id: StringName) -> float:
	var total := 0.0
	for skill in SKILL_CATALOG.skills:
		if skill == null or skill.effect_id != effect_id:
			continue
		total += skill.effect_value * get_skill_level(skill.id)
	return total



func save_game() -> void:
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
	points_changed.emit(points)
	coin_changed.emit(coin)
	for skill_id in skill_levels:
		skill_level_changed.emit(StringName(skill_id), int(skill_levels[skill_id]))


func _save_if_ready() -> void:
	if not _loading_save:
		save_game()
