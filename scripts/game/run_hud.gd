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

	var ground_active := pigeon.is_sprinting and not pigeon.sprint_is_air
	var air_active := pigeon.is_sprinting and pigeon.sprint_is_air

	var ground_progress := pigeon.get_ground_sprint_active_ratio() if ground_active else pigeon.get_ground_sprint_cooldown_ratio()
	var air_progress := pigeon.get_air_sprint_active_ratio() if air_active else pigeon.get_air_sprint_cooldown_ratio()

	var ground_remaining := pigeon.sprint_timer if ground_active else pigeon.sprint_ground_cooldown_timer
	var air_remaining := pigeon.sprint_timer if air_active else pigeon.sprint_air_cooldown_timer

	ground_burst_indicator.set_progress(ground_progress, ground_active, ground_remaining)
	air_burst_indicator.set_progress(air_progress, air_active, air_remaining)
