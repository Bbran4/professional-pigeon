extends Node
class_name PlayerInventory

var food: int = 0


func add_food(amount: int = 1) -> void:
	if amount <= 0:
		return

	food += amount


func can_spend_food(amount: int) -> bool:
	return amount >= 0 and food >= amount


func spend_food(amount: int) -> bool:
	if not can_spend_food(amount):
		return false

	food -= amount
	return true
