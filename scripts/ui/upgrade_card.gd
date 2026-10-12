extends PanelContainer
class_name UpgradeCard

## Reusable presentation base for upgrade cards. Put the title, description,
## cost and action controls inside the CardContent child in the inherited scene.
@export var title_text: String = "":
	set(value):
		title_text = value
		_sync_title()
@export_multiline var description_text: String = "":
	set(value):
		description_text = value
		_sync_description()
@export var accent_color: Color = Color(0.76, 0.59, 0.30, 1.0):
	set(value):
		accent_color = value
		_apply_accent()

@onready var title_label: Label = get_node_or_null("CardContent/Title") as Label
@onready var description_label: Label = get_node_or_null("CardContent/Description") as Label


func _ready() -> void:
	_sync_title()
	_sync_description()
	_apply_accent()


func _sync_title() -> void:
	if is_node_ready() and title_label != null:
		title_label.text = title_text


func _sync_description() -> void:
	if is_node_ready() and description_label != null:
		description_label.text = description_text


func _apply_accent() -> void:
	if not is_node_ready():
		return
	var style := get_theme_stylebox("panel").duplicate() as StyleBox
	if style is StyleBoxFlat:
		var flat := style as StyleBoxFlat
		flat.border_color = accent_color
		flat.set_border_width_all(2)
		add_theme_stylebox_override("panel", flat)
