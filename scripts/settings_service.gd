extends Node

## Runtime settings persisted independently from progression saves.
const CONFIG_PATH := "user://settings.cfg"
const SECTION := "settings"
const MASTER_BUS: StringName = &"Master"

var master_volume: float = 1.0
var fullscreen: bool = false
var vsync: bool = true


func _ready() -> void:
	_load_settings()
	_apply_all()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_master_volume()
	_save_settings()


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	_apply_fullscreen()
	_save_settings()


func set_vsync(enabled: bool) -> void:
	vsync = enabled
	_apply_vsync()
	_save_settings()


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	master_volume = clampf(float(config.get_value(SECTION, "master_volume", master_volume)), 0.0, 1.0)
	fullscreen = bool(config.get_value(SECTION, "fullscreen", fullscreen))
	vsync = bool(config.get_value(SECTION, "vsync", vsync))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, "master_volume", master_volume)
	config.set_value(SECTION, "fullscreen", fullscreen)
	config.set_value(SECTION, "vsync", vsync)
	var error := config.save(CONFIG_PATH)
	if error != OK:
		push_warning("SettingsService: Could not save settings (error %d)." % error)


func _apply_all() -> void:
	_apply_master_volume()
	_apply_fullscreen()
	_apply_vsync()


func _apply_master_volume() -> void:
	var bus_index := AudioServer.get_bus_index(MASTER_BUS)
	if bus_index < 0:
		push_warning("SettingsService: Audio bus 'Master' was not found.")
		return
	AudioServer.set_bus_mute(bus_index, master_volume <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(master_volume, 0.001)))


func _apply_fullscreen() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _apply_vsync() -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)
