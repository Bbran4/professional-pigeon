extends Node2D
class_name ParkPigeon

signal ate_bread(points: int)

enum ParkState { PERCHED, FLYING_TO_FOOD, SEARCHING, EATING, IDLE }

@export var points_per_bite: int = 1
@export var flight_duration: float = 1.4
@export var walk_speed: float = 90.0
@export var eating_duration: float = 0.65
@export var idle_duration: float = 1.2

var state: ParkState = ParkState.PERCHED
var active := false
var target_food: Node2D
var state_timer := 0.0
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var flight_elapsed := 0.0
var search_direction := 1.0

func _ready() -> void:
	start_position = position
	queue_redraw()

func _process(delta: float) -> void:
	if not active:
		return
	match state:
		ParkState.PERCHED:
			_update_perched(delta)
		ParkState.FLYING_TO_FOOD:
			_update_flight(delta)
		ParkState.SEARCHING:
			_update_searching(delta)
		ParkState.EATING:
			_update_eating(delta)
		ParkState.IDLE:
			_update_idle(delta)
	queue_redraw()

func start_day(food: Node2D) -> void:
	target_food = food
	active = true
	position = start_position
	state = ParkState.PERCHED
	state_timer = 0.6
	flight_elapsed = 0.0
	search_direction = 1.0

func end_day() -> void:
	active = false
	state = ParkState.PERCHED
	position = start_position
	target_food = null
	queue_redraw()

func _update_perched(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0 and is_instance_valid(target_food):
		state = ParkState.FLYING_TO_FOOD
		target_position = target_food.position
		flight_elapsed = 0.0

func _update_flight(delta: float) -> void:
	if not is_instance_valid(target_food):
		state = ParkState.PERCHED
		return
	flight_elapsed += delta
	var t := clampf(flight_elapsed / flight_duration, 0.0, 1.0)
	var eased := t * t * (3.0 - 2.0 * t)
	var arc := sin(t * PI) * -90.0
	position = start_position.lerp(target_position, eased) + Vector2(0.0, arc)
	if t >= 1.0:
		state = ParkState.SEARCHING
		state_timer = 0.35

func _update_searching(delta: float) -> void:
	state_timer -= delta
	position.x += search_direction * walk_speed * delta
	if absf(position.x - target_position.x) > 70.0:
		search_direction *= -1.0
	if state_timer <= 0.0:
		state = ParkState.EATING
		state_timer = eating_duration

func _update_eating(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		ate_bread.emit(points_per_bite)
		state = ParkState.IDLE
		state_timer = idle_duration

func _update_idle(delta: float) -> void:
	state_timer -= delta
	position.x += sin(Time.get_ticks_msec() * 0.004) * 5.0 * delta
	if state_timer <= 0.0:
		state = ParkState.SEARCHING
		state_timer = 0.5

func _draw() -> void:
	var body := Color("69717a")
	var dark := Color("3d4349")
	var light := Color("b8bec3")
	var beak := Color("d0a54b")
	draw_circle(Vector2.ZERO, 15.0, body)
	draw_circle(Vector2(10.0, -8.0), 10.0, light)
	draw_circle(Vector2(14.0, -10.0), 2.5, Color.WHITE)
	draw_circle(Vector2(14.5, -10.0), 1.2, Color("202020"))
	draw_colored_polygon(PackedVector2Array([Vector2(20,-8), Vector2(31,-4), Vector2(20,0)]), beak)
	var wing := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		wing.append(Vector2(-4, 2) + Vector2(cos(angle) * 13.0, sin(angle) * 8.0))
	draw_colored_polygon(wing, dark)
	draw_line(Vector2(-8, 14), Vector2(-8, 21), beak, 2.0)
	draw_line(Vector2(1, 13), Vector2(1, 21), beak, 2.0)
