extends Resource
class_name ResourceData

## Defines a resource that can exist in the game's economy.
##
## ResourceData is shared configuration. Quantities belong to an
## inventory or storage system, not to this resource definition.

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var base_value: int = 0
