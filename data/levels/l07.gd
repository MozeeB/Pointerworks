extends RefCounted
## L07 Foundry — jump across obstacles with a Teleporter pair.
##
## Emitter → TeleporterA (pair 0) → TeleporterB (pair 0) → Target.
## Shows that cursor velocity is preserved across the teleport.

const ID := "l07"
const DISPLAY_NAME := "Foundry"
const HINT := "Teleporter pair keeps cursor velocity across the jump."
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
		_pl(Vector2i(4, 4), PartData.Type.TELEPORTER, 0, 0),   # variant 0 = pair 0 A
		_pl(Vector2i(11, 4), PartData.Type.TELEPORTER, 0, 0),  # variant 0 = pair 0 B
		_pl(Vector2i(14, 4), PartData.Type.TARGET),
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
