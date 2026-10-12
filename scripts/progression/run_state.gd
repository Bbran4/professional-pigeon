extends Node

## Ephemeral state for the current day. Never written to the permanent save.
signal changed
signal day_started(duration: float)
signal day_ended(reward: int)

var active: bool = false
var time_remaining: float = 0.0
var earned_feathers: int = 0


func begin_day(duration: float) -> void:
	if active:
		return
	time_remaining = maxf(duration, 0.0)
	earned_feathers = 0
	active = true
	changed.emit()
	day_started.emit(time_remaining)


func advance_time(delta: float) -> void:
	if not active:
		return
	time_remaining = maxf(time_remaining - maxf(delta, 0.0), 0.0)
	changed.emit()


func add_feathers(amount: int) -> void:
	if not active or amount <= 0:
		return
	earned_feathers += amount
	changed.emit()


## Ends the active day once and returns the reward to the caller.
func finish_day() -> int:
	if not active:
		return 0
	active = false
	var reward := earned_feathers
	changed.emit()
	day_ended.emit(reward)
	return reward


## Clear transient state when abandoning a day or returning to the upgrade screen.
func reset() -> void:
	active = false
	time_remaining = 0.0
	earned_feathers = 0
	changed.emit()
