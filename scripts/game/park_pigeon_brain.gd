extends Node
class_name ParkPigeonBrain

## Coordinates a visitor's park-level lifecycle: arriving, waiting, feeding,
## dropping a feather, and departing. This is deliberately separate from the
## child StateMachine, which only controls the pigeon's movement/animation intent.
## Keep food, patience, timers, perch and exit decisions here; request IDLE/WALK/FLY
## from StateMachine rather than duplicating movement states in this lifecycle enum.

const BALANCE: GameBalance = preload("res://data/game_balance.tres")

signal ate_food(points: int)
signal feather_dropped(position: Vector2)
signal departed

## High-level visitor lifecycle, not locomotion state.
enum VisitorState {
	ARRIVING,
	WAITING,
	FEEDING,
	DROPPING,
	DEPARTING,
}

@export var eating_duration: float = BALANCE.default_eating_duration
@export var dropping_duration: float = BALANCE.default_dropping_duration
@export var food_points: int = 1
@export var food_distance: float = BALANCE.food_distance
@export var arrival_distance: float = BALANCE.arrival_distance
@export var departure_distance: float = BALANCE.departure_distance
@export var patience_timeout: float = BALANCE.default_patience_timeout

var active := false
var visitor_state: VisitorState = VisitorState.ARRIVING
var target_food: Node2D
var pending_food: Array[Node2D] = []
var eating_timer := 0.0
var feeding_remaining := 0.0
var feeding_drop_timer := 0.0
var dropping_timer := 0.0
var target_food_kind := "bread"
var waiting_timer := 0.0
var target_food_is_golden := false
var target_food_is_worm := false
var perch_position := Vector2.ZERO
var exit_position := Vector2.ZERO
var _last_requested_intent: int = -1
var _food_search_cooldown: float = 0.0


@onready var pigeon: Pigeon = get_parent() as Pigeon
@onready var state_machine: StateMachine = $"../StateMachine"
@onready var day_manager: DayManager = get_tree().get_first_node_in_group("day_manager") as DayManager


func _ready() -> void:
	state_machine.set_process(false)
	state_machine.set_physics_process(false)


func start_day(perch: Vector2, arrival: Vector2, exit: Vector2) -> void:
	perch_position = perch
	exit_position = exit
	active = true
	visitor_state = VisitorState.ARRIVING
	target_food = null
	pending_food.clear()
	eating_timer = 0.0
	feeding_remaining = 0.0
	feeding_drop_timer = 0.0
	target_food_kind = "bread"
	dropping_timer = 0.0
	waiting_timer = 0.0
	_food_search_cooldown = 0.0
	_last_requested_intent = -1

	pigeon.show()
	if pigeon.stats != null:
		pigeon.stats = pigeon.stats.duplicate() as PigeonStats
		pigeon.stats.flight_speed += ProgressionManager.get_effect_value(EffectIds.FLIGHT_SPEED_ADD)
	pigeon.global_position = arrival
	pigeon.velocity = Vector2.ZERO
	pigeon.move_direction = Vector2.ZERO
	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	_request_locomotion_intent(StateMachine.Intent.FLY)


func set_food(food: Node2D) -> void:
	if not active or visitor_state == VisitorState.DEPARTING:
		return
	if not is_instance_valid(food):
		return
	pending_food.append(food)
	_try_next_food()


func _physics_process(delta: float) -> void:
	if not active:
		return

	match visitor_state:
		VisitorState.ARRIVING:
			_move_toward(perch_position, arrival_distance, true)
			if pigeon.global_position.distance_to(perch_position) <= arrival_distance:
				pigeon.global_position = perch_position
				pigeon.move_direction = Vector2.ZERO
				visitor_state = VisitorState.WAITING
				waiting_timer = 0.0
				state_machine.transition(StateMachine.Intent.IDLE)
				_try_next_food()

		VisitorState.WAITING:
			_food_search_cooldown = maxf(0.0, _food_search_cooldown - delta)
			if not _food_is_available(target_food):
				target_food = null
				if _food_search_cooldown <= 0.0:
					_try_next_food()
			if target_food == null:
				waiting_timer += delta
				pigeon.move_direction = Vector2.ZERO
				state_machine.transition(StateMachine.Intent.IDLE)
				if waiting_timer >= patience_timeout:
					_begin_departure()
				return
			waiting_timer = 0.0
			_move_to_food(delta)

		VisitorState.FEEDING:
			pigeon.move_direction = Vector2.ZERO
			state_machine.transition(StateMachine.Intent.IDLE)
			feeding_remaining -= delta
			feeding_drop_timer -= delta
			if feeding_drop_timer <= 0.0:
				ate_food.emit(_get_food_points())
				feather_dropped.emit(pigeon.global_position + Vector2(BALANCE.feather_drop_offset_x, BALANCE.feather_drop_offset_y))
				feeding_drop_timer = maxf(BALANCE.minimum_dropping_duration, dropping_duration - ProgressionManager.get_effect_value(EffectIds.FEATHER_WAIT_REDUCTION)) if target_food_kind == "bread" else 1.0
			if feeding_remaining <= 0.0:
				target_food = null
				_begin_departure()

		VisitorState.DROPPING:
			# Kept as a compatibility state for existing saves/scenes. Food rewards
			# are now emitted on a timer during the feeding session itself.
			_begin_departure()

		VisitorState.DEPARTING:
			_move_toward(exit_position, departure_distance, true)
			if pigeon.global_position.distance_to(exit_position) <= departure_distance:
				active = false
				pigeon.hide()
				state_machine.set_process(false)
				state_machine.set_physics_process(false)
				departed.emit()


func _request_locomotion_intent(intent: StateMachine.Intent) -> void:
	# The brain runs every physics frame, but locomotion intent usually changes
	# only at visitor-state boundaries. Avoid repeating state-machine lookups.
	if _last_requested_intent == int(intent):
		return
	_last_requested_intent = int(intent)
	state_machine.transition(intent)


func _move_to_food(_delta: float) -> void:
	if not _food_is_available(target_food):
		target_food = null
		visitor_state = VisitorState.WAITING
		return
	var distance := pigeon.global_position.distance_to(target_food.global_position)
	if distance <= food_distance:
		pigeon.move_direction = Vector2.ZERO
		state_machine.transition(StateMachine.Intent.IDLE)
		if not target_food.has_method("claim") or not bool(target_food.call("claim")):
			target_food = null
			visitor_state = VisitorState.WAITING
			return
		target_food_is_golden = bool(target_food.get("is_golden"))
		target_food_is_worm = bool(target_food.get("is_worm"))
		target_food_kind = str(target_food.get("food_kind"))
		feeding_remaining = float(target_food.get("feeding_duration"))
		feeding_drop_timer = feeding_remaining
		if not target_food.call("consume_food"):
			target_food = null
			visitor_state = VisitorState.WAITING
			return
		visitor_state = VisitorState.FEEDING
		eating_timer = _get_eating_duration(target_food)
		feeding_remaining = maxf(feeding_remaining, eating_timer)
		feeding_drop_timer = 1.0 if target_food_kind == "seeds" else feeding_remaining
		waiting_timer = 0.0
		return
	_move_toward(target_food.global_position, food_distance, distance > BALANCE.fly_to_food_distance)


func _move_toward(target: Vector2, stop_distance: float, fly: bool) -> void:
	if pigeon.global_position.distance_to(target) <= stop_distance:
		pigeon.move_direction = Vector2.ZERO
		state_machine.transition(StateMachine.Intent.IDLE)
		return
	pigeon.move_direction = pigeon.global_position.direction_to(target)
	pigeon.update_facing()
	state_machine.transition(StateMachine.Intent.FLY if fly else StateMachine.Intent.WALK)


func _try_next_food() -> void:
	if not active or visitor_state != VisitorState.WAITING or target_food != null:
		return
	while not pending_food.is_empty():
		var next_food: Node2D = pending_food.pop_front() as Node2D
		if not _food_is_available(next_food):
			continue
		target_food = next_food
		return

	# Retry periodically rather than scanning every feeder every physics frame.
	# DayManager maintains this registry through feeder lifecycle signals.
	if _food_search_cooldown > 0.0:
		return
	_food_search_cooldown = BALANCE.food_search_interval
	if not is_instance_valid(day_manager):
		return

	var nearest_food: Node2D = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("food_pieces"):
		var candidate := node as Node2D
		if not _food_is_available(candidate):
			continue
		var distance := pigeon.global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_food = candidate
	if nearest_food != null:
		target_food = nearest_food


func _begin_departure() -> void:
	target_food = null
	pending_food.clear()
	visitor_state = VisitorState.DEPARTING
	pigeon.move_direction = Vector2.ZERO
	state_machine.transition(StateMachine.Intent.FLY)


func _get_food_points() -> int:
	var points := food_points + int(ProgressionManager.get_effect_value(EffectIds.POINTS_PER_SEED_ADD))
	if target_food_is_golden:
		points += BALANCE.golden_seed_bonus_points + int(ProgressionManager.get_effect_value(EffectIds.GOLDEN_SEED_BONUS))
	if target_food_is_worm:
		points += BALANCE.worm_bonus_points
		if ProgressionManager.get_effect_value(EffectIds.WORM_FOOD_UNLOCK) > 0.0:
			points += BALANCE.unlocked_worm_bonus_points
	return points


func _get_eating_duration(_food: Node2D) -> float:
	var duration := eating_duration - ProgressionManager.get_effect_value(EffectIds.EATING_TIME_REDUCTION)
	if target_food_is_worm and ProgressionManager.get_effect_value(EffectIds.WORM_FOOD_UNLOCK) > 0.0:
		duration += BALANCE.worm_extra_eating_duration
	return maxf(BALANCE.minimum_eating_duration, duration)


func _food_is_available(food: Node2D) -> bool:
	if not is_instance_valid(food) or not food.is_visible_in_tree():
		return false
	if food.has_method("can_feed"):
		return bool(food.call("can_feed"))
	return true
