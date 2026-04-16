extends RefCounted
## L08 Assembly — full factory line using all 7 parts in one design.
##
## Route: Emitter → SpeedFast → Splitter. UP branch turns RIGHT,
## teleports across, hits T1 at bottom-right. DOWN branch turns RIGHT,
## slows down, hits T2 in mid-right. Wall at (5,7) is decorative.
##
## Demonstrates the complete toolkit; a single emit fires both
## targets (par_cursors = 1).

const ID := "l08"
const DISPLAY_NAME := "Assembly"
const HINT := "All seven parts, one machine."
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
		_pl(Vector2i(3, 4), PartData.Type.SPEED_MOD, 0, 1),   # ×2
		_pl(Vector2i(5, 7), PartData.Type.WALL),              # decorative
		_pl(Vector2i(7, 4), PartData.Type.SPLITTER),
		_pl(Vector2i(7, 1), PartData.Type.DEFLECTOR, 0),      # UP → RIGHT
		_pl(Vector2i(7, 7), PartData.Type.DEFLECTOR, 2),      # DOWN → RIGHT
		_pl(Vector2i(10, 7), PartData.Type.SPEED_MOD, 0, 0),  # ×0.5
		_pl(Vector2i(11, 1), PartData.Type.TELEPORTER, 0, 0), # pair 0 A
		_pl(Vector2i(1, 8), PartData.Type.TELEPORTER, 0, 0),  # pair 0 B
		_pl(Vector2i(14, 8), PartData.Type.TARGET),
		_pl(Vector2i(14, 7), PartData.Type.TARGET),
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
