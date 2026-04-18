extends RefCounted
## L03 Forge — wall blocks straight line. Route around with 2 deflectors.
##
## Pre-laid: emitter, three-cell wall column, target on the far side.
## Palette: 2 Deflectors.
## Solution: deflector (3,4) [steps 0 → DOWN], deflector (3,7) [steps 2 → RIGHT].
## Press R to rotate the second deflector twice (steps 0 → 1 → 2).

const ID := "l03"
const DISPLAY_NAME := "Forge"
const HINT := "Walls kill cursors. Route around. R rotates a placed part."
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
		# Three-cell wall blocks the y=4 row beyond x=5.
		_pl(Vector2i(5, 3), PartData.Type.WALL),
		_pl(Vector2i(5, 4), PartData.Type.WALL),
		_pl(Vector2i(5, 5), PartData.Type.WALL),
		_pl(Vector2i(10, 7), PartData.Type.TARGET),
	]
	lvl.palette_types = [3]  # DEFLECTOR
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
