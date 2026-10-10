extends Node

signal points_changed(points: int)
signal coin_changed(coin: int)
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var points: int = 0
var coin: int = 0
var skill_levels: Dictionary = {}


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	points += amount
	points_changed.emit(points)


func add_coin(amount: int) -> void:
	if amount <= 0:
		return
	coin += amount
	coin_changed.emit(coin)


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
	return true


func spend_coin(amount: int) -> bool:
	if not can_spend_coin(amount):
		return false
	coin -= amount
	coin_changed.emit(coin)
	return true


func spend(points_amount: int, coin_amount: int) -> bool:
	if not can_spend(points_amount, coin_amount):
		return false
	points -= points_amount
	coin -= coin_amount
	points_changed.emit(points)
	coin_changed.emit(coin)
	return true


func get_skill_level(skill_id: StringName) -> int:
	return int(skill_levels.get(skill_id, 0))


func set_skill_level(skill_id: StringName, level: int) -> void:
	skill_levels[skill_id] = maxi(level, 0)
	skill_level_changed.emit(skill_id, maxi(level, 0))


func get_effect_value(effect_id: StringName) -> float:
	var total := 0.0
	for skill in SKILL_CATALOG.skills:
		if skill == null or skill.effect_id != effect_id:
			continue
		total += skill.effect_value * get_skill_level(skill.id)
	return total
