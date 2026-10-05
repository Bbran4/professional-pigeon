extends CanvasLayer
class_name RunHud

@onready var run_manager: RunManager = $"../RunManager"
@onready var timer_label: Label = $MarginContainer/Panel/VBox/TimerLabel
@onready var food_label: Label = $MarginContainer/Panel/VBox/FoodLabel
@onready var coin_label: Label = $MarginContainer/Panel/VBox/CoinLabel


func _process(_delta: float) -> void:
	if run_manager == null:
		return

	timer_label.text = "Timer: %02d" % ceili(run_manager.time_remaining)
	food_label.text = "Food: %d" % run_manager.player.inventory.food
	coin_label.text = "Coin: %d" % run_manager.player.inventory.coin
