extends Node
class_name PlayerInventory

var food: int = 0
var coin: int = 0


func add_food(amount: int = 1) -> void:
	if amount > 0:
		food += amount


func add_coin(amount: int = 1) -> void:
	if amount > 0:
		coin += amount


func clear() -> void:
	food = 0
	coin = 0
