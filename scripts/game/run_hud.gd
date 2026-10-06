extends CanvasLayer
class_name RunHud

@onready var run_manager: RunManager = $"../RunManager"
@onready var timer_label: Label = $MarginContainer/Panel/VBox/TimerLabel
@onready var food_label: Label = $MarginContainer/Panel/VBox/FoodLabel
@onready var coin_label: Label = $MarginContainer/Panel/VBox/CoinLabel
@onready var ground_burst_indicator: CooldownIndicator = $MarginContainer/Panel/VBox/BurstIndicators/GroundBurst
@onready var air_burst_indicator: CooldownIndicator = $MarginContainer/Panel/VBox/BurstIndicators/AirBurst


func _process(_delta: float) -> void:
	if run_manager == null:
		return

	timer_label.text = "Timer: %02d" % ceili(run_manager.time_remaining)
	food_label.text = "Food: %d" % run_manager.player.inventory.food
	coin_label.text = "Coin: %d" % run_manager.player.inventory.coin

	var pigeon := run_manager.player as Pigeon
	if pigeon == null:
		return

	_update_burst(ground_burst_indicator, pigeon, false)
	_update_burst(air_burst_indicator, pigeon, true)


func _update_burst(indicator: CooldownIndicator, pigeon: Pigeon, air: bool) -> void:
	var active := pigeon.is_sprinting and pigeon.sprint_is_air == air
	indicator.set_progress(pigeon.get_sprint_ratio(air), active, pigeon.get_sprint_remaining(air))
