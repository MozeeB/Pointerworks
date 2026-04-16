extends RefCounted
## L10 Cyclotron — 2 emitters, 2 teleporter pairs, 4 targets.
##
## Each emitter feeds a chain: cursor passes through the first target
## (Target doesn't consume), hits a teleporter, exits on the opposite
## row, passes through the second target. Par = 2 (one cursor per emit).

const ID := "l10"
const DISPLAY_NAME := "Cyclotron"
const HINT := "Two loops, four targets. Hover both emitters."
const PAR_CURSORS := 2


static func build() -> LevelResource:
	var lvl := LevelResource.new()
	lvl.id = ID
	lvl.display_name = DISPLAY_NAME
	lvl.hint = HINT
	lvl.par_cursors = PAR_CURSORS
	lvl.grid_size = Vector2i(16, 10)
	lvl.placements = [
		# Top loop
		_pl(Vector2i(1, 1), PartData.Type.EMITTER),
		_pl(Vector2i(5, 1), PartData.Type.TARGET),        # pass-through
		_pl(Vector2i(10, 1), PartData.Type.TELEPORTER, 0, 0),  # pair 0 A
		_pl(Vector2i(1, 5), PartData.Type.TELEPORTER, 0, 0),   # pair 0 B
		_pl(Vector2i(14, 5), PartData.Type.TARGET),

		# Bottom loop
		_pl(Vector2i(1, 8), PartData.Type.EMITTER),
		_pl(Vector2i(5, 8), PartData.Type.TARGET),
		_pl(Vector2i(10, 8), PartData.Type.TELEPORTER, 0, 1),  # pair 1 A
		_pl(Vector2i(1, 4), PartData.Type.TELEPORTER, 0, 1),   # pair 1 B
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
