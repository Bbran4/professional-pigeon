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
@export_range(1.0, 5.0, 0.05) var cost_growth: float = 1.5
@export var tree_position: Vector2 = Vector2.ZERO
@export var coming_soon: bool = false
@export var prerequisites: Array[StringName] = []
@export var effect_id: StringName
@export var effect_value: float = 0.0
@export_range(1, 100, 1) var max_level: int = 1


## Return a description derived from the same effect data used by progression.
## The authored description remains the fallback for qualitative/unlock effects.
func get_effect_description() -> String:
	var amount := _format_effect_value(effect_value)
	match effect_id:
		EffectIds.DAY_DURATION_ADD:
			return "Add %s seconds to every day per level." % amount
		EffectIds.ARRIVAL_SPEED_REDUCTION:
			return "Reduce the gap between arrivals by %s seconds per level." % amount
		EffectIds.EATING_TIME_REDUCTION:
			return "Reduce pigeon eating time by %s seconds per level." % amount
		EffectIds.FLIGHT_SPEED_ADD:
			return "Increase pigeon flight speed by %s per level." % amount
		EffectIds.FEATHER_WAIT_REDUCTION:
			return "Reduce the feather-drop wait by %s seconds per level." % amount
		EffectIds.POINTS_PER_SEED_ADD:
			return "Earn %s extra Feather(s) per seed eaten, per level." % amount
		EffectIds.SEED_REGEN_INTERVAL:
			return "Set the seed refill interval to %s seconds." % amount
		EffectIds.SEED_REGEN_INTERVAL_REDUCTION:
			return "Reduce the seed refill interval by %s seconds per level." % amount
		EffectIds.GOLDEN_SEED_CHANCE:
			return "Increase the golden-seed chance by %s%% per level." % _format_effect_value(effect_value * 100.0)
		EffectIds.GOLDEN_SEED_BONUS:
			return "Golden seeds award %s extra Feather(s)." % amount
		EffectIds.WORM_FOOD_UNLOCK:
			return "Unlock worms as food. " + description
		EffectIds.PIGEON_PATIENCE_ADD:
			return "Visitors wait %s extra seconds before leaving an empty feeder, per level." % amount
		EffectIds.RARE_VISITOR_CHANCE:
			return "Increase the rare-visitor chance by %s%% per level." % _format_effect_value(effect_value * 100.0)
		EffectIds.PAIR_ARRIVALS:
			return "Increase the chance of paired pigeon arrivals by %s%% per level." % _format_effect_value(effect_value * 100.0)
		EffectIds.BENCH_COUNT_ADD:
			return "Unlock %s additional bench(es) and their perch spots." % amount
		EffectIds.FOUNTAIN_UNLOCK:
			return "Unlock the fountain and its perch spots."
		EffectIds.TREE_NESTS:
			return "Unlock tree-nest perches that increase visitor capacity."
		EffectIds.FEATHER_COUNT_ADD:
			return "Drop %s additional feather(s) after a successful visit, per level." % amount
		EffectIds.FEATHER_VALUE_ADD:
			return "Increase the Feather reward by %s per level." % amount
		EffectIds.GOLDEN_FEATHER_CHANCE:
			return "Increase the golden-feather chance by %s%% per level." % _format_effect_value(effect_value * 100.0)
		EffectIds.CROW_COLLECT_INTERVAL:
			return "A crow collects one collectible every %s seconds." % amount
		EffectIds.SEED_CAPACITY_ADD:
			return "Increase feeder capacity by %s seed(s) per level." % amount
		EffectIds.SEEDS_SPAWNS:
			return "Increase the seed supply by %s per level." % amount
		EffectIds.WORMS_SPAWNS:
			return "Increase the worm supply by %s per level." % amount
		EffectIds.MAX_PIGEONS:
			return "Increase the number of pigeons allowed in the park at once by %s per level." % amount
		EffectIds.FEATHER_COLLECT_TIME_REDUCTION:
			return "Reduce feather collection time by %s seconds per level." % amount
		EffectIds.FEATHER_COLLECT_RADIUS:
			return "Increase the feather collection radius by %s pixels per level." % amount
		_:
			return description


func _format_effect_value(value: float) -> String:
	var result := String.num(value, 2)
	while result.contains(".") and result.ends_with("0"):
		result = result.trim_suffix("0")
	if result.ends_with("."):
		result = result.trim_suffix(".")
	return result
