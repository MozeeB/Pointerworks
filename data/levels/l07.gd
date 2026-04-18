extends RefCounted
## L07 Foundry — pre-laid Teleporter A. Player places Teleporter B + 1 deflector.
##
## Pre-laid: emitter, TeleporterA pair0, three-cell wall, target.
## Palette: 1 Teleporter (variant=0 → pairs with the pre-laid one).
## Solution: place TeleporterB at (10,4). Cursor enters A, exits B going RIGHT,
## skips the wall completely, hits target.

const ID := "l07"
const DISPLAY_NAME := "Foundry"
const HINT := "Place a teleporter past the wall. Both auto-pair (pair_id 0)."
const PAR_CURSORS := 1


static func build() -> LevelResource:
	var lvl := LevelResource.new()
	lvl.id = ID
	lvl.display_name = DISPLAY_NAME
	lvl.hint = HINT
	lvl.par_cursors = PAR_CURSORS
	lvl.grid_size = Vector2i(16, 10)
	lvl.placements = [
		_pl(Vector2i(1, 4), PartData.Type.EMITTER),
		_pl(Vector2i(5, 4), PartData.Type.TELEPORTER, 0, 0),  # pre-laid pair 0
		_pl(Vector2i(8, 3), PartData.Type.WALL),
		_pl(Vector2i(8, 4), PartData.Type.WALL),
		_pl(Vector2i(8, 5), PartData.Type.WALL),
		_pl(Vector2i(14, 4), PartData.Type.TARGET),
	]
	# 6 = TELEPORTER (variant 0 default → pairs with pre-laid pair 0)
	lvl.palette_types = [6]
	lvl.palette_counts = [1]
	return lvl


static func _pl(cell: Vector2i, type: int, rotation_steps: int = 0, variant: int = 0) -> PartPlacement:
	var pp := PartPlacement.new()
	pp.cell = cell
	var d := PartData.new()
	d.type = type
	d.rotation_steps = rotation_steps
	d.variant = variant
	pp.data = d
	pp.locked = true
	return pp
