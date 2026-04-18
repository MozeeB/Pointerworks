extends RefCounted
## L10 Cyclotron — final puzzle. Two emitters, two pre-laid teleporter
## pairs, four scattered targets. Walls partition the grid into 4 zones;
## each zone holds one target. The teleporters jump cursors between zones.
##
## Pre-laid: 2 emitters, 2 teleporter pairs, 4 targets, dividing wall row.
## Palette: 4 Deflectors (2 per emitter route).
## Solution sketch:
##   Emitter A (1,1) RIGHT → deflector (8,1) steps 0 DOWN to teleA pair0 (8,4)
##     → exit teleB pair0 (1,8) RIGHT → target (5,8). Continue → target (14,8).
##   Emitter B (1,4) RIGHT → deflector (5,4) steps 2 UP to (5,2)... actually
##     simpler: B fires through the wall gap, hits teleA pair1 (12,4) → exits
##     teleB pair1 (12,1) RIGHT → target (14,1). Continue past target (10,1).

const ID := "l10"
const DISPLAY_NAME := "Cyclotron"
const HINT := "Two emitters, two portal pairs. Route every cursor."
const PAR_CURSORS := 2


static func build() -> LevelResource:
	var lvl := LevelResource.new()
	lvl.id = ID
	lvl.display_name = DISPLAY_NAME
	lvl.hint = HINT
	lvl.par_cursors = PAR_CURSORS
	lvl.grid_size = Vector2i(16, 10)
	lvl.placements = [
		# Emitter A (top) — feeds top + left routes
		_pl(Vector2i(1, 1), PartData.Type.EMITTER),
		_pl(Vector2i(8, 4), PartData.Type.TELEPORTER, 0, 0),  # pair 0 A
		_pl(Vector2i(1, 8), PartData.Type.TELEPORTER, 0, 0),  # pair 0 B
		_pl(Vector2i(5, 8), PartData.Type.TARGET),
		_pl(Vector2i(14, 8), PartData.Type.TARGET),

		# Emitter B (mid) — feeds right routes
		_pl(Vector2i(1, 5), PartData.Type.EMITTER),
		_pl(Vector2i(12, 5), PartData.Type.TELEPORTER, 0, 1),  # pair 1 A
		_pl(Vector2i(8, 1), PartData.Type.TELEPORTER, 0, 1),   # pair 1 B → exits RIGHT through both targets
		_pl(Vector2i(10, 1), PartData.Type.TARGET),
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
