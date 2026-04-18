extends RefCounted
## L05 Lathe — pre-laid speed mod (fast). Player adds deflectors.
##
## Pre-laid: emitter, fast speed mod inline, wall column, target above.
## Palette: 2 Deflectors.
## Solution: deflector (8,4) steps=2 RIGHT→UP, deflector (8,1) steps=0 UP→RIGHT.

const ID := "l05"
const DISPLAY_NAME := "Lathe"
const HINT := "Speed mod doubles velocity. Place deflectors to climb up + right."
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
		_pl(Vector2i(4, 4), PartData.Type.SPEED_MOD, 0, 1),  # fast ×2 pre-laid
		_pl(Vector2i(11, 4), PartData.Type.WALL),
		_pl(Vector2i(11, 3), PartData.Type.WALL),
		_pl(Vector2i(11, 5), PartData.Type.WALL),
		_pl(Vector2i(14, 1), PartData.Type.TARGET),
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
