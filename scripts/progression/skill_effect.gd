extends Resource
class_name SkillEffect

## How this effect combines with a stat's base value.
enum Mode {
	ADD,
	MULTIPLY
}

@export var effect_id: StringName
@export var mode: Mode = Mode.ADD
@export var value: float = 0.0
