extends PanelContainer
class_name SettingsPanel

@onready var volume_slider: HSlider = $Content/MasterVolume
@onready var fullscreen_check: CheckBox = $Content/Fullscreen
@onready var vsync_check: CheckBox = $Content/VSync

const MASTER_BUS := &"Master"

func _ready() -> void:
	volume_slider.value = _get_master_volume()
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)

func _get_master_volume() -> float:
	var bus_index := AudioServer.get_bus_index(MASTER_BUS)
	if bus_index < 0:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index)) if not AudioServer.is_bus_mute(bus_index) else 0.0

func _on_volume_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(MASTER_BUS)
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, value <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.001)))

func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED)
