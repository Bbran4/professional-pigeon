extends Node
class_name RunManager

signal run_ended(reason: String, food_collected: int)

@export var run_duration: float = 60.0

var time_remaining: float
var remaining_bread: int
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
	remaining_bread = get_tree().get_nodes_in_group("bread").size()

	if player == null:
		push_error("RunManager requires a Player.")
		return

	if not player.bread_collected.is_connected(_on_bread_collected):
		player.bread_collected.connect(_on_bread_collected)

	player.set_run_active(true)

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

	var food_collected := player.inventory.food

	reason_label.text = get_end_reason_text(reason)
	food_label.text = "Food collected: %d" % food_collected
	result_panel.show()

	run_ended.emit(reason, food_collected)

	print("Run ended: ", reason, " | Food collected: ", food_collected)


func restart_run() -> void:
	get_tree().reload_current_scene()


func get_end_reason_text(reason: String) -> String:
	if reason == "all_bread_collected":
		return "All bread collected!"

	return "Time's up!"
