extends RefCounted
class_name EffectIds

## Canonical IDs used by SkillData.effect_id and ProgressionManager.get_effect_value().
const ARRIVAL_SPEED_REDUCTION: StringName = &"arrival_speed_reduction"
const BENCH_COUNT_ADD: StringName = &"bench_count_add"
const CROW_COLLECT_INTERVAL: StringName = &"crow_collect_interval"
const DAY_DURATION_ADD: StringName = &"day_duration_add"
const EATING_TIME_REDUCTION: StringName = &"eating_time_reduction"
const FEATHER_COUNT_ADD: StringName = &"feather_count_add"
const FEATHER_VALUE_ADD: StringName = &"feather_value_add"
const FEATHER_WAIT_REDUCTION: StringName = &"feather_wait_reduction"
const FLIGHT_SPEED_ADD: StringName = &"flight_speed_add"
const FOUNTAIN_UNLOCK: StringName = &"fountain_unlock"
const GOLDEN_FEATHER_CHANCE: StringName = &"golden_feather_chance"
const GOLDEN_SEED_BONUS: StringName = &"golden_seed_bonus"
const GOLDEN_SEED_CHANCE: StringName = &"golden_seed_chance"
const PAIR_ARRIVALS: StringName = &"pair_arrivals"
const PIGEON_PATIENCE_ADD: StringName = &"pigeon_patience_add"
const POINTS_PER_SEED_ADD: StringName = &"points_per_seed_add"
const RARE_VISITOR_CHANCE: StringName = &"rare_visitor_chance"
const SEED_REGEN_INTERVAL: StringName = &"seed_regen_interval"
const SEED_REGEN_INTERVAL_REDUCTION: StringName = &"seed_regen_interval_reduction"
const TREE_NESTS: StringName = &"tree_nests"
const WORM_FOOD_UNLOCK: StringName = &"worm_food_unlock"
const BASIC_FEEDING: StringName = &"basic_feeding"
const UNLOCK_SEEDS: StringName = &"unlock_seeds"
const UNLOCK_WORMS: StringName = &"unlock_worms"
const WORMS_SPAWNS: StringName = &"worms_spawns"
const SEED_CAPACITY_ADD: StringName = &"seed_capacity_add"
const SEEDS_SPAWNS: StringName = &"seeds_spawns"
const MAX_PIGEONS: StringName = &"max_pigeons"
const BENCH_FEEDER: StringName = &"bench_feeder"
const AUTO_COLLECT: StringName = &"auto_collect"
const FEATHER_COLLECT_TIME_REDUCTION: StringName = &"feather_collect_time_reduction"
const FEATHER_COLLECT_RADIUS: StringName = &"feather_collect_radius"



static func is_valid_id(effect_id: StringName) -> bool:
	return effect_id in [
		ARRIVAL_SPEED_REDUCTION,
		BENCH_COUNT_ADD,
		CROW_COLLECT_INTERVAL,
		DAY_DURATION_ADD,
		EATING_TIME_REDUCTION,
		FEATHER_COUNT_ADD,
		FEATHER_VALUE_ADD,
		FEATHER_WAIT_REDUCTION,
		FLIGHT_SPEED_ADD,
		FOUNTAIN_UNLOCK,
		GOLDEN_FEATHER_CHANCE,
		GOLDEN_SEED_BONUS,
		GOLDEN_SEED_CHANCE,
		PAIR_ARRIVALS,
		PIGEON_PATIENCE_ADD,
		POINTS_PER_SEED_ADD,
		RARE_VISITOR_CHANCE,
		SEED_REGEN_INTERVAL,
		SEED_REGEN_INTERVAL_REDUCTION,
		TREE_NESTS,
		WORM_FOOD_UNLOCK,
		BASIC_FEEDING,
		UNLOCK_SEEDS,
		UNLOCK_WORMS,
		WORMS_SPAWNS,
		SEED_CAPACITY_ADD,
		SEEDS_SPAWNS,
		MAX_PIGEONS,
		BENCH_FEEDER,
		AUTO_COLLECT,
		FEATHER_COLLECT_TIME_REDUCTION,
		FEATHER_COLLECT_RADIUS,
	]
