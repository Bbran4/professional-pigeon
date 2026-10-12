extends CanvasLayer

@onready var resume_button: Button = $Overlay/Center/Panel/Content/Buttons/Resume
@onready var settings_button: Button = $Overlay/Center/Panel/Content/Buttons/Settings
@onready var main_menu_button: Button = $Overlay/Center/Panel/Content/Buttons/MainMenu
@onready var settings_panel: SettingsPanel = $Overlay/Center/Panel/Content/SettingsPanel
@onready var settings_back_button: Button = $Overlay/Center/Panel/Content/SettingsBack


func _ready() -> void:
	resume_button.pressed.connect(resume_game)
	settings_button.pressed.connect(_show_settings)
	main_menu_button.pressed.connect(_return_to_main_menu)
	settings_back_button.pressed.connect(_show_pause_actions)
	$Overlay.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()
		get_viewport().set_input_as_handled()


func pause_game() -> void:
	get_tree().paused = true
	_show_pause_actions()
	$Overlay.show()


func resume_game() -> void:
	get_tree().paused = false
	$Overlay.hide()


func _show_pause_actions() -> void:
	$Overlay/Center/Panel/Content/Buttons.show()
	settings_panel.hide()
	settings_back_button.hide()


func _show_settings() -> void:
	$Overlay/Center/Panel/Content/Buttons.hide()
	settings_panel.show()
	settings_back_button.show()


func _return_to_main_menu() -> void:
	ProgressionManager.save_game()
	get_tree().paused = false
	SceneManager.change_to(&"main_menu")
