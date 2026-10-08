extends Node

signal food_changed(food: int)
signal coin_changed(coin: int)
signal skill_level_changed(skill_id: StringName, new_level: int)

var food: int = 0
var coin: int = 0
var skill_levels: Dictionary = {}


func add_food(amount: int) -> void:
	if amount <= 0:
		return
	food += amount
	food_changed.emit(food)


func add_coin(amount: int) -> void:
	if amount <= 0:
		return
	coin += amount
	coin_changed.emit(coin)


func can_spend_food(amount: int) -> bool:
	return amount >= 0 and food >= amount


func can_spend_coin(amount: int) -> bool:
	return amount >= 0 and coin >= amount


func can_spend(food_amount: int, coin_amount: int) -> bool:
	return can_spend_food(food_amount) and can_spend_coin(coin_amount)


func spend_food(amount: int) -> bool:
	if not can_spend_food(amount):
		return false
	food -= amount
	food_changed.emit(food)
	return true


func spend_coin(amount: int) -> bool:
	if not can_spend_coin(amount):
		return false
	coin -= amount
	coin_changed.emit(coin)
	return true


func spend(food_amount: int, coin_amount: int) -> bool:
	if not can_spend(food_amount, coin_amount):
		return false
	food -= food_amount
	coin -= coin_amount
	food_changed.emit(food)
	coin_changed.emit(coin)
	return true


func get_skill_level(skill_id: StringName) -> int:
	return int(skill_levels.get(skill_id, 0))


func set_skill_level(skill_id: StringName, level: int) -> void:
	skill_levels[skill_id] = level
	skill_level_changed.emit(skill_id, level)
