extends Node
class_name RunManager

signal run_ended(reason: String, food_collected: int)

@export var run_duration: float = 60.0

var time_remaining: float
var remaining_bread: int
var active: bool = true

@onready var player: Player = $"../Player"


func _ready() -> void:
	call_deferred("start_run")


func _process(delta: float) -> void:
	if not active:
		return

	time_remaining = maxf(time_remaining - delta, 0.0)

	if time_remaining <= 0.0:
		end_run("time_up")


func start_run() -> void:
	time_remaining = run_duration
	remaining_bread = get_tree().get_nodes_in_group("bread").size()

	if player == null:
		push_error("RunManager requires a Player.")
		return

	player.bread_collected.connect(_on_bread_collected)

	if remaining_bread == 0:
		end_run("all_bread_collected")


func _on_bread_collected() -> void:
	if not active:
		return

	remaining_bread = max(remaining_bread - 1, 0)

	if remaining_bread == 0:
		end_run("all_bread_collected")


func end_run(reason: String) -> void:
	if not active:
		return

	active = false
	player.set_run_active(false)
	run_ended.emit(reason, player.inventory.food)

	print("Run ended: ", reason, " | Food collected: ", player.inventory.food)
