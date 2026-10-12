extends RefCounted
class_name CurrencyIds

## Canonical IDs for currencies used by the wallet and skill costs.
const FEATHERS: StringName = &"feathers"
const COINS: StringName = &"coins"

static func is_valid_id(currency_id: StringName) -> bool:
	return currency_id == FEATHERS or currency_id == COINS
