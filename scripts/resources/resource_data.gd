extends Resource
class_name ResourceData

## Defines one collectible resource in the game's economy.
## Quantities belong to an inventory or progression system.

enum ResourceType {
	FOOD,
	COIN
}

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var resource_type: ResourceType = ResourceType.FOOD
@export var base_value: int = 1
@export_range(0.0, 1000.0, 0.1) var spawn_weight: float = 100.0
