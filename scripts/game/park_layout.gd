extends Node
class_name ParkLayout

## Shared park bounds used for procedural overflow positions only.
## Actual visitor entry, exit, and normal perch locations are scene markers.

@export var visitor_bounds := Rect2(40.0, 100.0, 1072.0, 500.0)
