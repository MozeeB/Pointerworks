extends RefCounted
## L09 Reactor — 4 targets in 2 rows. Player adds 2 deflectors.
##
## Pre-laid: emitter, splitter, four targets in two rows.
## Palette: 2 Deflectors (one per branch).
## Solution: deflector (5,1) steps 0 UP→RIGHT, deflector (5,7) steps 2 DOWN→RIGHT.
## Single cursor → splitter → both branches → deflectors → all 4 targets via
## pass-through. Optimal par = 1 emit.

const ID := "l09"
const DISPLAY_NAME := "Reactor"
const HINT := "4 targets. One cursor through the splitter lights every row."
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
		_pl(Vector2i(5, 4), PartData.Type.SPLITTER),
		# Top row
		_pl(Vector2i(10, 1), PartData.Type.TARGET),
		_pl(Vector2i(14, 1), PartData.Type.TARGET),
		# Bottom row
		_pl(Vector2i(10, 7), PartData.Type.TARGET),
		_pl(Vector2i(14, 7), PartData.Type.TARGET),
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
