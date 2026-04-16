extends RefCounted
## L02 Press — introduce 90° routing via Deflector.
##
## Emitter fires right; Deflector (steps=0 → +90° CW) redirects the
## cursor DOWN into a Target below.

const ID := "l02"
const DISPLAY_NAME := "Press"
const HINT := "Deflectors turn cursors 90° clockwise."
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
		_pl(Vector2i(10, 2), PartData.Type.DEFLECTOR, 0),
		_pl(Vector2i(10, 8), PartData.Type.TARGET),
	]
	lvl.palette_types = []
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
