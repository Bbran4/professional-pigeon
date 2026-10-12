# Performance Profiling Before Object Pooling

## Goal

Measure the current game before introducing object pooling. Pooling adds lifecycle complexity, so only add it if profiling shows that repeated scene instantiation or destruction is a meaningful bottleneck.

## Current candidates to measure

- **Visitors:** `scripts/game/pigeon_spawner.gd` instantiates pigeons and queues them for deletion after departure or day cleanup.
- **Feathers:** `scripts/game/collectible_drop_service.gd` instantiates individual feather scenes, including extra drops from upgrades.
- **Gameplay scripts:** pigeon brains, `DayManager` completion checks, and feeder regeneration may contribute CPU time independently of scene churn.
- **Rendering and physics:** active node count, collision objects, and visible feathers may cost more than allocation itself.

These are hypotheses, not confirmed bottlenecks.

## Repeatable baseline

Use the same Godot build, window size, scene, upgrades, and test duration for each run.

1. Run a debug build of the game and open **Debugger → Profiler** and **Debugger → Monitors**.
2. Start a day and let the normal visitor loop run for 60 seconds.
3. Repeat with upgrades that increase visitor count, feather drops, and feather value/count where available.
4. Repeat a run where many feathers accumulate before being collected or cleared.
5. Record the profiler's frame-time distribution and the hottest functions. Also record object/node counts and memory usage from Monitors where available.
6. Run each scenario at least three times and compare typical results, not just a single worst frame.

Record:
- Godot version, build mode, display resolution, and hardware.
- Scenario and relevant upgrade levels.
- Typical frame time/FPS and worst recurring frame-time spikes.
- Time attributed to scripts, physics, rendering, and scene instantiation/deletion where the profiler exposes it.
- Peak node/object counts and memory usage.
- Whether spikes consistently coincide with pigeon or feather spawn/cleanup.

## Decision rule

Do **not** add pooling just because scenes are instantiated frequently.

Consider a small, targeted pooling experiment only if repeated profiles show that instantiation/destruction contributes materially to recurring frame-time spikes in a representative worst-case scenario. Change one object type at a time, then rerun the same scenarios and compare results.

Keep pooling only if it improves measured frame time or stability without causing stale signal connections, duplicated registration, reset-state bugs, or objects surviving day/scene cleanup. Otherwise, keep the simpler instantiate/queue-free lifecycle.

## Current status

No runtime performance measurements are recorded in this document yet. A code review identifies candidate hotspots but cannot replace profiling the running game.
