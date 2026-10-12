extends Control

@onready var settings_panel: SettingsPanel = $Center/Panel/Content/SettingsPanel
@onready var play_button: Button = $Center/Panel/Content/Buttons/Play
@onready var settings_button: Button = $Center/Panel/Content/Buttons/Settings
@onready var quit_button: Button = $Center/Panel/Content/Buttons/Quit
@onready var settings_back_button: Button = $Center/Panel/Content/SettingsBack


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_back_button.pressed.connect(_on_settings_back_pressed)
	_show_main_actions()


func _show_main_actions() -> void:
	$Center/Panel/Content/Buttons.show()
	settings_panel.hide()
	settings_back_button.hide()


func _on_play_pressed() -> void:
	SceneManager.change_to(&"upgrades")


func _on_settings_pressed() -> void:
	$Center/Panel/Content/Buttons.hide()
	settings_panel.show()
	settings_back_button.show()


func _on_settings_back_pressed() -> void:
	_show_main_actions()


func _on_quit_pressed() -> void:
	get_tree().quit()
