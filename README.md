# Professional Pigeon

**Professional Pigeon** is a 2D incremental game about managing a park, attracting pigeons, collecting feathers, and investing the rewards into upgrades.

## Current gameplay

The current prototype uses a **60-second day**.

1. Start the day.
2. The active feeder attracts a pigeon.
3. The pigeon arrives, eats a seed for 2 seconds, waits 2 seconds, drops a feather, then leaves.
4. Keep the cursor over each feather for 3 seconds to collect it and earn Coin. Collect all feathers before starting another day or opening Unlocks.
5. Food eaten earns Points at the end of the day.
6. Spend Points and Coin on skills, then start another day.

There is **no manual bread throwing or manual feeding**.

## Feeders and progression

- A starter feeder is available from the beginning, so the first day can be played without any skill purchase.
- **Basic Feeding** is the first feeding skill and prerequisite for the first progression branches.
- The **Bench Feeder** skill costs 5 Points and 1 Coin, and requires Basic Feeding. It unlocks the feeder beside the bench and its three pigeon spawn markers.
- Until the Bench Feeder is unlocked, pigeons use the starter feeder and the general landing spots.
- The FountainMarker is a placeholder for future use.
- **Larger Seed Tray** costs 20 Points and 2 Coin, and increases the active feeder's seed capacity.
- Unlocking Seeds enables the additional seed-supply upgrade.

## Skill tree

Skill definitions in `data/skills/*.tres` own their prerequisites, tree positions, Coming Soon status, base costs, and cost-growth multiplier. The tree generates its buttons from the catalog, so adding or moving a skill no longer requires hand-editing the scene. Repeated purchases scale each cost by `base cost × cost_growth^current level` (default growth: 1.5).

The tree includes branches for:

- Bench Feeder and seed capacity
- Seeds and worms
- Coin and currency upgrades (farthings, pennies, and nobles)

The old manual-bread upgrades have been retired with the bread-throwing mechanic. Bread projectiles and bread stock are no longer part of the game loop.

The Seeds upgrade increases feeder capacity after Seeds is unlocked. Worms, the Coin unlock node, and currency-denomination pickup upgrades are marked **Coming Soon** and cannot currently be purchased. Coin is still useful for the Bench Feeder and Larger Seed Tray upgrades.

## Saving and loading

Progression is saved automatically to `user://professional_pigeon_save.json`. The save includes Points, Coin, and purchased skill levels. The active day timer and current feeder stock are not saved.

## Technical details

- **Engine:** Godot 4.x
- **Language:** GDScript
- **Genre:** 2D single-player incremental / idle game
- **Startup scene:** `scenes/progression/upgrade_screen.tscn`
- **Park gameplay scene:** `scenes/game.tscn`
- **Progression:** `scripts/progression/progression_manager.gd`
- **Pigeon behaviour:** `scripts/game/park_pigeon_brain.gd`
- **Feather collection:** `scripts/game/feather_collector.gd`

## Next development priorities

1. Verify the feeder/day loop in Godot.
2. Connect remaining resource upgrades to actual world pickup spawning.
3. Add more visible park changes as skills are purchased.
4. Expand day results and long-term progression.


### Visitor capacity

The **More Pigeons** upgrade increases the number of simultaneous visitors by one per level, up to three. Visitors reserve distinct perch markers from the `perch_spots` group, and feeders are discovered through the `feeders` group, allowing additional benches and feeders to participate without hard-coded node paths. Visitors that cannot find food leave after their patience timeout instead of waiting forever.
