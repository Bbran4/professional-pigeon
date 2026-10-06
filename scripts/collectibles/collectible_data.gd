extends Resource
class_name CollectibleData

enum CollectibleType {
	FOOD,
	COIN
}

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var collectible_type: CollectibleType = CollectibleType.FOOD
@export var base_value: int = 1
@export_range(0, 1000, 1) var base_spawn_amount: int = 0
@export_range(0.0, 100.0, 0.1) var spawn_chance: float = 100.0
@export var unlock_skill_id: StringName
@export var spawn_upgrade_id: StringName

## Presentation and collision data for the generic collectible scene.
@export var visual_color: Color = Color.WHITE
@export var visual_polygon: PackedVector2Array
