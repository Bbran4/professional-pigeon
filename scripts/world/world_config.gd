extends RefCounted
class_name WorldConfig

## Shared dimensions and bounds for the playable world.
const WORLD_LEFT := 0.0
const WORLD_RIGHT := 6000.0
const WORLD_WIDTH := WORLD_RIGHT - WORLD_LEFT

const GROUND_TOP := 568.0
const GROUND_HEIGHT := 80.0
const GROUND_BOTTOM := GROUND_TOP + GROUND_HEIGHT

const SPAWN_MARGIN := 24.0
const SPAWN_WORLD_START := WORLD_LEFT + SPAWN_MARGIN
const SPAWN_WORLD_END := WORLD_RIGHT - SPAWN_MARGIN
