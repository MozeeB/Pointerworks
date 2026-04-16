class_name PartPlacement
extends Resource
## PartPlacement — one entry in a LevelResource.placements array.
##
## Pairs a grid cell with a PartData blob. LevelLoader iterates these
## at scene-spawn time, instantiates the corresponding Part scene, and
## hands it off to GridSystem.place_part.

@export var cell: Vector2i = Vector2i.ZERO
@export var data: PartData
## If true, the player CANNOT remove or modify this placement during BUILD.
## Use for walls / pre-baked targets / emitters that define the puzzle.
@export var locked: bool = true


## Renamed from `duplicate_deep` — Godot 4.6 added that name to the
## Resource base class.
func clone_deep() -> PartPlacement:
	var copy := PartPlacement.new()
	copy.cell = cell
	if data != null:
		var d := PartData.new()
		d.type = data.type
		d.rotation_steps = data.rotation_steps
		d.variant = data.variant
		d.palette_color = data.palette_color
		copy.data = d
	copy.locked = locked
	return copy
