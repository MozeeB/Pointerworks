extends RefCounted
## L01 Conveyor — teach the core loop.
##
## Hover the amber emitter → a virtual cursor flies right → hits the
## cyan target. Simplest possible machine.

const ID := "l01"
const DISPLAY_NAME := "Conveyor"
const HINT := "Hover the emitter. Watch the cursor fly."
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
		_pl(Vector2i(14, 4), PartData.Type.TARGET),
	]
	lvl.palette_types = []  # pre-laid for L01
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
