extends RefCounted
## L02 Press — first puzzle. Player places one Deflector.
##
## Pre-laid: emitter (1,4) + target (8,8).
## Palette: 1 Deflector.
## Solution: place deflector at (8,4). Click slot, click cell. Cursor
## flies right, bends 90° down at the deflector, hits target.

const ID := "l02"
const DISPLAY_NAME := "Press"
const HINT := "Click the deflector slot, then click cell (8,4) to place it."
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
		_pl(Vector2i(8, 8), PartData.Type.TARGET),
	]
	# 3 = DEFLECTOR
	lvl.palette_types = [3]
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
