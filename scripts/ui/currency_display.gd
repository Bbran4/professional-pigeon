extends HBoxContainer
class_name CurrencyDisplay

## Reusable balance readout. Set currency_id in the Inspector before adding to a scene.
@export var currency_id: StringName = CurrencyIds.FEATHERS
@export var display_name: String = ""
@export var prefix: String = ""
@export var suffix: String = ""

@onready var amount_label: Label = $Amount


func _ready() -> void:
	Wallet.changed.connect(_on_currency_changed)
	_refresh()


func _exit_tree() -> void:
	if Wallet.changed.is_connected(_on_currency_changed):
		Wallet.changed.disconnect(_on_currency_changed)


func _on_currency_changed(changed_id: StringName, _amount: int) -> void:
	if changed_id == currency_id:
		_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	var currency_name := display_name
	if currency_name.is_empty():
		currency_name = String(currency_id).capitalize()
	amount_label.text = "%s%s: %s%s" % [
		prefix,
		currency_name,
		_format_amount(ProgressionManager.get_currency_balance(currency_id)),
		suffix
	]


func _format_amount(amount: int) -> String:
	return String.num_int64(amount)
