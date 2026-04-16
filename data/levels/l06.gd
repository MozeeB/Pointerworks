extends RefCounted
## L06 Kiln — slow a cursor for tighter routing (Speed Modifier ×0.5).
##
## Emitter → SpeedMod ×0.5 → Deflector → Target. A slower cursor leaves
## thicker trails; easier to read complex machines later.

const ID := "l06"
const DISPLAY_NAME := "Kiln"
const HINT := "Slow modifier ×0.5. Trails stay longer on-screen."
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
		_pl(Vector2i(5, 2), PartData.Type.SPEED_MOD, 0, 0),  # variant 0 = slow ×0.5
		_pl(Vector2i(11, 2), PartData.Type.DEFLECTOR, 0),    # steps 0 → turn RIGHT→DOWN
		_pl(Vector2i(11, 8), PartData.Type.TARGET),
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
