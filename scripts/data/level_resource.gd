class_name LevelResource
extends Resource
## LevelResource — authoritative data for a single level (`l01.tres` …).
##
## Everything needed to spawn the playable scene + grade completion.
## Author via Godot inspector or `.tres` by hand.

@export var id: String = "l01"
## Display name — must be an industrial-machine word per the Theme
## (Conveyor, Press, Forge, Refinery, Lathe, Kiln, Foundry, Assembly,
## Reactor, Cyclotron).
@export var display_name: String = "Conveyor"
@export_multiline var hint: String = ""
@export var grid_size: Vector2i = Vector2i(16, 10)
## Target cursor count: player earns ⭐ if they solve with ≤ par.
@export var par_cursors: int = 1
@export var placements: Array[PartPlacement] = []
## Part types the player can drag from the palette during BUILD.
## Empty array = palette hidden (puzzle is fully pre-laid).
@export var palette_types: Array[int] = []
## Counts available per palette slot (-1 = unlimited). Index matches palette_types.
@export var palette_counts: Array[int] = []


func has_palette() -> bool:
	return not palette_types.is_empty()
