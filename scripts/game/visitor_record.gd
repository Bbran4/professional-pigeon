extends RefCounted
class_name VisitorRecord

## Runtime record for a spawned visitor and its allocated perch.
var pigeon: Pigeon
var brain: ParkPigeonBrain
var perch_key: String

func _init(p_pigeon: Pigeon = null, p_brain: ParkPigeonBrain = null, p_perch_key: String = "") -> void:
	pigeon = p_pigeon
	brain = p_brain
	perch_key = p_perch_key
