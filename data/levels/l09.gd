extends RefCounted
## L09 Reactor — optimize: 4 targets, par enforces a tight cursor count.
##
## Splitter forks once; each branch deflects + slowed; 2 teleporter pairs
## ferry the stream across a wall divider to hit 4 targets from a single emit.

const ID := "l09"
const DISPLAY_NAME := "Reactor"
const HINT := "Four targets. One cursor. Minimize waste."
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
		_pl(Vector2i(4, 4), PartData.Type.SPLITTER),
		# UP branch: goes up to deflector, turns right, hits target, then teleporter to lower-right for second target.
		_pl(Vector2i(4, 1), PartData.Type.DEFLECTOR, 0),   # UP → RIGHT
		_pl(Vector2i(8, 1), PartData.Type.TARGET),
		_pl(Vector2i(14, 1), PartData.Type.TELEPORTER, 0, 0),  # pair 0 A
		_pl(Vector2i(1, 7), PartData.Type.TELEPORTER, 0, 0),   # pair 0 B, exit still RIGHT
		_pl(Vector2i(5, 7), PartData.Type.TARGET),
		# DOWN branch: goes down to deflector, turns right, slow, hits target, teleports to top-right.
		_pl(Vector2i(4, 7), PartData.Type.DEFLECTOR, 2),   # DOWN → RIGHT
		_pl(Vector2i(7, 7), PartData.Type.SPEED_MOD, 0, 0),  # slow
		_pl(Vector2i(10, 7), PartData.Type.TARGET),
		_pl(Vector2i(14, 7), PartData.Type.TELEPORTER, 0, 1),  # pair 1 A
		_pl(Vector2i(8, 4), PartData.Type.TELEPORTER, 0, 1),   # pair 1 B, exit RIGHT
		_pl(Vector2i(13, 4), PartData.Type.TARGET),
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
