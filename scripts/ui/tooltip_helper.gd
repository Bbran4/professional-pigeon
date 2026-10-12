extends RefCounted
class_name TooltipHelper

## Applies consistent tooltip copy and optional custom tooltip text to a Control.
static func set_tooltip(control: Control, title: String, description: String) -> void:
	if control == null:
		return
	control.tooltip_text = title if description.is_empty() else "%s\n%s" % [title, description]
