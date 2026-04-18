extends RefCounted
## L06 Kiln — pre-laid slow speed mod. Player routes around an L-wall.
##
## Pre-laid: emitter, slow speed mod inline, L-shaped wall, target below-right.
## Palette: 2 Deflectors.
## Solution: deflector (8,2) steps=0 RIGHT→DOWN, deflector (8,5) steps=2 DOWN→RIGHT.

const ID := "l06"
const DISPLAY_NAME := "Kiln"
const HINT := "Slow mod halves speed. Two deflectors form an L-route to the target."
const PAR_CURSORS := 1


static func build() -> LevelResource:
	var lvl := LevelResource.new()
	lvl.id = ID
	lvl.display_name = DISPLAY_NAME
	lvl.hint = HINT
	lvl.par_cursors = PAR_CURSORS
	lvl.grid_size = Vector2i(16, 10)
	lvl.placements = [
		_pl(Vector2i(1, 2), PartData.Type.EMITTER),
		_pl(Vector2i(4, 2), PartData.Type.SPEED_MOD, 0, 0),  # slow ×0.5 pre-laid
		_pl(Vector2i(11, 2), PartData.Type.WALL),
		_pl(Vector2i(11, 3), PartData.Type.WALL),
		_pl(Vector2i(11, 4), PartData.Type.WALL),
		_pl(Vector2i(14, 5), PartData.Type.TARGET),
	]
	lvl.palette_types = [3]
	lvl.palette_counts = [2]
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
