extends Resource
class_name ResourceData

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
