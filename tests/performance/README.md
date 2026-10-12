# Stress Testing Visitors, Feeders, and Collectibles

## Run

From the repository root with Godot 4.x installed:

```sh
godot --path . res://tests/performance/stress_test.tscn
```

The test runs the actual game scene, then adds a configurable stress load of active pigeon brains, feeder instances, and feather collectibles. It prints one-second CSV samples to the Godot output and exits after 60 seconds by default.

Default load:
- 100 active visitors
- 100 feeders
- 500 feather collectibles
- 60-second sample duration

Open `tests/performance/stress_test.tscn` in Godot to adjust the exported counts and duration before running. Use the same Godot version, display size, renderer, build mode, and machine when comparing runs.

## Measurements

CSV columns include:
- Frame delta in milliseconds, sampled every frame for peak frame-time calculation
- Godot process and physics process time monitors
- Static memory in MiB
- Object and node counts
- Active 2D physics object count
- Stress-test visitor, feeder, and collectible counts

The final `STRESS_TEST_SUMMARY` line reports the peak frame delta and peak sampled static memory. The per-second CSV is suitable for saving as a baseline. Use Godot's built-in Profiler and Monitors alongside this harness to identify which functions or subsystems consume the time.

## Scenarios

Run at least three times per scenario:
1. Baseline: 10 visitors, 10 feeders, 50 collectibles.
2. Expected heavy load: 100 visitors, 100 feeders, 500 collectibles.
3. High load: 250 visitors, 200 feeders, 1,000 collectibles.
4. Collectible-heavy: 25 visitors, 25 feeders, 2,000 collectibles.

Record results in a separate table with Godot version, build mode, resolution, hardware, scenario counts, median and peak frame time, and peak static memory. Compare the same scenario before and after any performance optimization.

## Interpretation and limitations

This is a stress harness, not an automated pass/fail test. It measures load behavior but does not define a universal acceptable frame-time or memory threshold. A frame delta is the elapsed frame duration, not pure CPU execution time; consult the Godot profiler for attribution. Static memory is sampled once per second, so brief memory spikes can be missed.

The harness activates the visitors' park brains and assigns feeders, while keeping many collectibles on screen. It does not reproduce every natural arrival/departure and collection sequence exactly. Run a normal gameplay profile too, and do not introduce object pooling unless measurements show repeated instantiation/destruction is a meaningful cost.
