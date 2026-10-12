extends Control
class_name UpgradeScreen

@onready var start_day_button: Button = $TopBar/TopBarContent/StartDayButton
@onready var reset_save_button: Button = $TopBar/TopBarContent/ResetSaveButton
@onready var main_menu_button: Button = $TopBar/TopBarContent/MainMenuButton
@onready var reset_confirmation: ConfirmationDialog = $ResetConfirmation


func _ready() -> void:
	start_day_button.pressed.connect(_on_start_day_pressed)
	reset_save_button.pressed.connect(_on_reset_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	reset_confirmation.confirmed.connect(_on_reset_save_confirmed)
	ConfirmationDialogHelper.configure(
		reset_confirmation,
		"Reset Save",
		"Delete all saved Feathers and purchased upgrades?",
		"RESET",
		"CANCEL"
	)
	ProgressionManager.points_changed.connect(refresh.unbind(1))
	ProgressionManager.skill_level_changed.connect(_on_skill_level_changed)
	refresh()


func _on_skill_level_changed(_skill_id: StringName, _new_level: int) -> void:
	refresh()


func refresh() -> void:
	start_day_button.disabled = false


func _on_reset_save_pressed() -> void:
	reset_confirmation.popup_centered()


func _on_reset_save_confirmed() -> void:
	ProgressionManager.reset_save()
	refresh()


func _exit_tree() -> void:
	ProgressionManager.save_game()


func _on_start_day_pressed() -> void:
	ProgressionManager.save_game()
	SceneManager.change_to(&"park")


func _on_main_menu_pressed() -> void:
	ProgressionManager.save_game()
	SceneManager.change_to(&"main_menu")
