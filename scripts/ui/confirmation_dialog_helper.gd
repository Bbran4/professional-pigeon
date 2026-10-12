extends RefCounted
class_name ConfirmationDialogHelper

## Standardises the common setup for destructive-action confirmation dialogs.
static func configure(
	dialog: ConfirmationDialog,
	dialog_title: String,
	message: String,
	confirm_text: String = "CONFIRM",
	cancel_text: String = "CANCEL"
) -> void:
	if dialog == null:
		return
	dialog.title = dialog_title
	dialog.dialog_text = message
	dialog.ok_button_text = confirm_text
	dialog.cancel_button_text = cancel_text
