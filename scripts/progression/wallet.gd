extends Node

## Owns currency balances and all balance mutations.
signal changed(currency_id: StringName, amount: int)

var balances: Dictionary = {}


func get_balance(currency_id: StringName) -> int:
	return int(balances.get(currency_id, 0))


func add(currency_id: StringName, amount: int) -> bool:
	if not CurrencyIds.is_valid_id(currency_id) or amount <= 0:
		return false
	set_balance(currency_id, get_balance(currency_id) + amount)
	return true


func can_spend(currency_id: StringName, amount: int) -> bool:
	return CurrencyIds.is_valid_id(currency_id) and amount >= 0 and get_balance(currency_id) >= amount


func spend(currency_id: StringName, amount: int) -> bool:
	if not can_spend(currency_id, amount):
		return false
	set_balance(currency_id, get_balance(currency_id) - amount)
	return true


func set_balance(currency_id: StringName, amount: int) -> bool:
	if not CurrencyIds.is_valid_id(currency_id):
		push_warning("Wallet: unknown currency ID '%s'." % currency_id)
		return false
	var safe_amount := maxi(amount, 0)
	if get_balance(currency_id) == safe_amount:
		return true
	balances[currency_id] = safe_amount
	changed.emit(currency_id, safe_amount)
	return true


func load_balances(saved_balances: Dictionary) -> void:
	balances.clear()
	for currency_id in saved_balances:
		var id := StringName(str(currency_id))
		if CurrencyIds.is_valid_id(id):
			balances[id] = maxi(int(saved_balances[currency_id]), 0)
	for currency_id in [CurrencyIds.FEATHERS, CurrencyIds.COINS]:
		changed.emit(currency_id, get_balance(currency_id))


func reset() -> void:
	for currency_id in [CurrencyIds.FEATHERS, CurrencyIds.COINS]:
		set_balance(currency_id, 0)
