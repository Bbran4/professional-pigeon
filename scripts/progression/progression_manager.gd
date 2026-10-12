extends Node

## Compatibility facade for game systems. Domain work is delegated to Wallet,
## ProgressionState, and SaveService so existing callers keep a stable API.
signal points_changed(points: int)
signal skill_level_changed(skill_id: StringName, new_level: int)

const SKILL_CATALOG: SkillCatalog = preload("res://data/skills/skill_catalog.tres")

var points: int:
	get:
		return Wallet.balance

var skill_levels: Dictionary:
	get:
		return ProgressionState.levels


func _ready() -> void:
	Wallet.balance_changed.connect(_on_balance_changed)
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


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	Wallet.add(amount)
	SaveService.mark_dirty()


func can_spend_points(amount: int) -> bool:
	return Wallet.can_spend(amount)


func can_spend(amount: int) -> bool:
	return can_spend_points(amount)


func spend_points(amount: int) -> bool:
	if not Wallet.spend(amount):
		return false
	SaveService.mark_dirty()
	return true


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


func reset_save() -> void:
	Wallet.set_balance(0)
	ProgressionState.reset()
	SaveService.clear_save()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_game()


func save_game() -> void:
	if not SaveService.is_dirty():
		return
	var saved_levels: Dictionary = {}
	for skill_id in skill_levels:
		saved_levels[String(skill_id)] = int(skill_levels[skill_id])
	SaveService.save_data({
		"version": 1,
		"points": points,
		"skill_levels": saved_levels,
	})


func _load_game() -> void:
	var save_data := SaveService.load_data()
	if save_data.is_empty():
		return
	Wallet.set_balance(maxi(int(save_data.get("points", 0)), 0))
	var saved_levels: Variant = save_data.get("skill_levels", {})
	if saved_levels is Dictionary:
		ProgressionState.load_levels(saved_levels)
	ProgressionState.emit_loaded_levels()


func _on_balance_changed(amount: int) -> void:
	points_changed.emit(amount)


func _on_skill_level_changed(skill_id: StringName, new_level: int) -> void:
	skill_level_changed.emit(skill_id, new_level)
