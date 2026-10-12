extends Node

## Owns the Feather balance and all balance mutations.
signal balance_changed(amount: int)

var balance: int = 0


func add(amount: int) -> void:
	if amount <= 0:
		return
	balance += amount
	balance_changed.emit(balance)


func can_spend(amount: int) -> bool:
	return amount >= 0 and balance >= amount


func spend(amount: int) -> bool:
	if not can_spend(amount):
		return false
	balance -= amount
	balance_changed.emit(balance)
	return true


func set_balance(amount: int) -> void:
	var safe_amount := maxi(amount, 0)
	balance = safe_amount
	balance_changed.emit(balance)
