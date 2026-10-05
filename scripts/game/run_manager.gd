extends Node
class_name RunManager

signal run_ended(reason: String, food_collected: int, coin_collected: int)

@export var run_duration: float = 60.0

var time_remaining: float
var remaining_collectibles: int
var active: bool = true

@onready var player: Player = $"../Player"
@onready var result_panel: Control = $"../RunEndLayer/RunEndPanel"
@onready var food_label: Label = $"../RunEndLayer/RunEndPanel/Panel/FoodLabel"
@onready var reason_label: Label = $"../RunEndLayer/RunEndPanel/Panel/ReasonLabel"


func _ready() -> void:
	result_panel.hide()
	call_deferred("start_run")


func _process(delta: float) -> void:
	if not active:
		return

	time_remaining = maxf(time_remaining - delta, 0.0)

	if time_remaining <= 0.0:
		end_run("time_up")


func start_run() -> void:
	active = true
	result_panel.hide()
	time_remaining = run_duration
	remaining_collectibles = get_tree().get_nodes_in_group("collectible").size()

	if player == null:
		push_error("RunManager requires a Player.")
		return

	if not player.collectible_collected.is_connected(_on_collectible_collected):
		player.collectible_collected.connect(_on_collectible_collected)

	player.set_run_active(true)

	if remaining_collectibles == 0:
		end_run("all_collectibles_collected")


func _on_collectible_collected() -> void:
	if not active:
		return

	remaining_collectibles = max(remaining_collectibles - 1, 0)

	if remaining_collectibles == 0:
		end_run("all_collectibles_collected")


func end_run(reason: String) -> void:
	if not active:
		return

	active = false
	player.set_run_active(false)

	var food_collected := player.inventory.food
	var coin_collected := player.inventory.coin

	ProgressionManager.add_food(food_collected)
	ProgressionManager.add_coin(coin_collected)
	player.inventory.clear()

	reason_label.text = get_end_reason_text(reason)
	food_label.text = "Food: +%d   |   Coin: +%d" % [food_collected, coin_collected]
	result_panel.show()

	run_ended.emit(reason, food_collected, coin_collected)

	print("Run ended: ", reason, " | Food: ", food_collected, " | Coin: ", coin_collected)


func restart_run() -> void:
	get_tree().reload_current_scene()


func get_end_reason_text(reason: String) -> String:
	if reason == "all_collectibles_collected":
		return "Everything collected!"

	return "Time's up!"
