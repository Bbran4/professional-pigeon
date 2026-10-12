extends Node

## Compatibility facade for game systems. Domain work is delegated to Wallet,
## ProgressionState, and SaveService so existing callers keep a stable API.
signal points_changed(points: int)
signal currency_changed(currency_id: StringName, amount: int)
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var points: int:
	get:
		return Wallet.get_balance(CurrencyIds.FEATHERS)

var skill_levels: Dictionary:
	get:
		return ProgressionState.levels


func _ready() -> void:
	Wallet.changed.connect(_on_currency_changed)
	ProgressionState.skill_level_changed.connect(_on_skill_level_changed)
	_load_game()
	if OS.is_debug_build():
		SKILL_CATALOG.validate()


func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_F3:
			add_points(1000)
			get_viewport().set_input_as_handled()


func get_currency_balance(currency_id: StringName) -> int:
	return Wallet.get_balance(currency_id)


func add_currency(currency_id: StringName, amount: int) -> bool:
	if not Wallet.add(currency_id, amount):
		return false
	SaveService.mark_dirty()
	return true


func can_spend_currency(currency_id: StringName, amount: int) -> bool:
	return Wallet.can_spend(currency_id, amount)


func spend_currency(currency_id: StringName, amount: int) -> bool:
	if not Wallet.spend(currency_id, amount):
		return false
	SaveService.mark_dirty()
	return true


func add_points(amount: int) -> void:
	add_currency(CurrencyIds.FEATHERS, amount)


func can_spend_points(amount: int) -> bool:
	return can_spend_currency(CurrencyIds.FEATHERS, amount)


func can_spend(amount: int) -> bool:
	return can_spend_points(amount)


func spend_points(amount: int) -> bool:
	return spend_currency(CurrencyIds.FEATHERS, amount)


func spend(amount: int) -> bool:
	return spend_points(amount)


func get_skill_level(skill_id: StringName) -> int:
	return ProgressionState.get_skill_level(skill_id)


func set_skill_level(skill_id: StringName, level: int) -> void:
	var safe_level := maxi(level, 0)
	if get_skill_level(skill_id) == safe_level:
		return
	ProgressionState.set_skill_level(skill_id, safe_level)
	SaveService.mark_dirty()


func get_effect_value(effect_id: StringName) -> float:
	return ProgressionState.get_effect_value(effect_id)


func get_stat(stat_id: StringName, base_value: float) -> float:
	return ProgressionState.get_stat(stat_id, base_value)


func reset_save() -> void:
	Wallet.reset()
	ProgressionState.reset()
	SaveService.clear_save()
	points_changed.emit(0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_game()


func save_game() -> void:
	if not SaveService.is_dirty():
		return
	var saved_levels: Dictionary = {}
	for skill_id in skill_levels:
		saved_levels[String(skill_id)] = int(skill_levels[skill_id])
	var saved_balances: Dictionary = {}
	for currency_id in Wallet.balances:
		saved_balances[String(currency_id)] = int(Wallet.balances[currency_id])
	SaveService.save_data({
		"version": 2,
		"balances": saved_balances,
		"skill_levels": saved_levels,
	})


func _load_game() -> void:
	var save_data := SaveService.load_data()
	if save_data.is_empty():
		return
	var saved_balances: Variant = save_data.get("balances", {})
	if saved_balances is Dictionary:
		Wallet.load_balances(saved_balances)
	else:
		# Migrate the original version-1 single-currency save format.
		Wallet.set_balance(CurrencyIds.FEATHERS, maxi(int(save_data.get("points", 0)), 0))
	var saved_levels: Variant = save_data.get("skill_levels", {})
	if saved_levels is Dictionary:
		ProgressionState.load_levels(saved_levels)
	ProgressionState.emit_loaded_levels()


func _on_currency_changed(currency_id: StringName, amount: int) -> void:
	currency_changed.emit(currency_id, amount)
	if currency_id == CurrencyIds.FEATHERS:
		points_changed.emit(amount)


func _on_skill_level_changed(skill_id: StringName, new_level: int) -> void:
	skill_level_changed.emit(skill_id, new_level)
