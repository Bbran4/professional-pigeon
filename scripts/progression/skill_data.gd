extends Resource
class_name SkillData

enum Category {
	FOOD,
	PLAYER_UPGRADES,
	ABILITIES,
	BOOSTS,
	NPC_PIGEONS
}

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var category: Category = Category.FOOD
@export_range(0, 100000, 1) var points_cost: int = 0
@export_range(0, 100000, 1) var coin_cost: int = 0
@export_range(1.0, 5.0, 0.05) var cost_growth: float = 1.5
@export var tree_position: Vector2 = Vector2.ZERO
@export var coming_soon: bool = false
@export var prerequisites: Array[StringName] = []
@export var effect_id: StringName
@export var effect_value: float = 0.0
@export_range(1, 100, 1) var max_level: int = 1
