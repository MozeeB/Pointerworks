extends RefCounted
## L05 Lathe — accelerate for long runs (Speed Modifier ×2).
##
## Emitter → SpeedMod ×2 → target at the far side of the grid. Shows
## how fast-mod shortens transit time across a big empty floor.

const ID := "l05"
const DISPLAY_NAME := "Lathe"
const HINT := "Speed modifiers scale velocity. Fast = ×2."
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
		_pl(Vector2i(5, 4), PartData.Type.SPEED_MOD, 0, 1),  # variant 1 = fast ×2
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
