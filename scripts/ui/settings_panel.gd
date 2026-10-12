extends PanelContainer
class_name SettingsPanel

@onready var volume_slider: HSlider = $Content/MasterVolume
@onready var fullscreen_check: CheckBox = $Content/Fullscreen
@onready var vsync_check: CheckBox = $Content/VSync


func _ready() -> void:
	volume_slider.set_value_no_signal(SettingsService.master_volume)
	fullscreen_check.set_pressed_no_signal(SettingsService.fullscreen)
	vsync_check.set_pressed_no_signal(SettingsService.vsync)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)


func _on_volume_changed(value: float) -> void:
	SettingsService.set_master_volume(value)


func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsService.set_fullscreen(enabled)


func _on_vsync_toggled(enabled: bool) -> void:
	SettingsService.set_vsync(enabled)
