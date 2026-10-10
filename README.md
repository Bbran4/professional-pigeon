# Professional Pigeon

**Professional Pigeon** is a 2D incremental game about managing a park, attracting pigeons, collecting feathers, and investing the rewards into upgrades.

## Current gameplay

The current prototype uses a **60-second day**.

1. Start the day.
2. The active feeder attracts a pigeon.
3. The pigeon arrives, eats a seed for 2 seconds, waits 2 seconds, drops a feather, then leaves.
4. Hover over a feather to collect Coin. Collection speed and radius can be upgraded, and later upgrades automate pickup.
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

Skill definitions are stored in `data/skills/skill_catalog.tres`. The catalog contains both external `.tres` resources and inline skill subresources, and owns their prerequisites, tree positions, Coming Soon status, base costs, and cost-growth multipliers. The tree generates its buttons from the catalog, so adding or moving a skill no longer requires hand-editing the scene. Repeated purchases scale each cost by `base cost × cost_growth^current level` (default growth: 1.5).

The tree includes branches for:

- Bench Feeder and seed capacity
- Seeds and worms
- Time and flow, food and Points, pigeon capacity, park expansion, and collectible progression

The old manual-bread upgrades have been retired with the bread-throwing mechanic. Bread projectiles and bread stock are no longer part of the game loop.

The tree now contains 50 catalog entries, including time, food, visitor, park, and collection upgrades. Farthing, penny, and noble pickups are no longer part of progression; feathers and other pickups share the `Collectible` base and award Coin through `coin_value`. Coin remains a spendable upgrade currency.

## Development controls

- Press **F3** in a debug build to add 1,000 Points.
- Use **RESET SAVE** on the upgrade screen to clear saved Points, Coin, and skill levels after confirming.

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

1. Playtest the full progression path in Godot, including purchases, day completion, and save persistence.
2. Tune upgrade balance using Points earned per day.
3. Add a day-summary panel, pecking audio, feather pickup feedback, and readable number formatting.


### Visitor capacity

The **More Pigeons** upgrade increases the number of simultaneous visitors by one per level, up to five when Tree Nests is fully unlocked. Visitors reserve distinct perch markers from the `perch_spots` group, and feeders are discovered through the `feeders` group, allowing additional benches and feeders to participate without hard-coded node paths. Visitors that cannot find food leave after their patience timeout instead of waiting forever.

### Feather collection progression

Feather collection scales with the flock through three upgrades: **Quick Collection** reduces hover time by 0.85 seconds per level (down to a 0.5-second minimum), **Wide Sweep** adds 20 pixels of collection radius per level, and **Pigeon Post** automatically collects visible feathers. Uncollected feathers no longer block starting a new day or opening the upgrades screen.


### Upgrade pool

The current catalog contains 50 skills. It includes five separate +5-second day upgrades, arrival/eating/flight pacing, Points per seed, seed regeneration, golden seeds, worm food, visitor patience and rare arrivals, pairs, three extra benches, fountain and tree nests, plus feather count/value/rarity and a periodic crow collector. Some park effects are generated at park startup from purchased progression.
