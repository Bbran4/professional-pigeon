extends Node

## Cross-system gameplay events. Emitters remain authoritative for their own data.
signal currency_changed(currency_id: StringName, amount: int)
signal visitor_spawned(visitor: Node)
signal visitor_departed(visitor: Node)
signal collectible_spawned(collectible: Node)
signal collectible_collected(collectible: Node, points: int)
signal progression_unlocked(skill_id: StringName)
signal run_completed(reward: int)
