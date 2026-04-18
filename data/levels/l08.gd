extends RefCounted
## L08 Assembly — pre-laid splitter. Player places 2 deflectors + 1 teleporter.
##
## Pre-laid: emitter (1,4), splitter (5,4), wall column (10,3-5), targets at
## (14,1) and (14,7), TeleporterA pair0 at (8,1).
## Palette: 2 Deflectors + 1 Teleporter.
## Solution:
##   - Up branch: deflector (5,1) [steps 0 UP→RIGHT] → reaches TeleporterA at
##     (8,1) → exits player-placed TeleporterB (best at (12,7)) RIGHT → hits
##     bottom target (14,7).
##   - Down branch: deflector (5,7) [steps 2 DOWN→RIGHT] → travels to (14,7)
##     also hitting bottom target (pass-through).
##   - Wait — with one teleporter B placement we only solve one branch. So
##     the player must instead place the teleporter to send the up-branch
##     across to the top-target row, and the down-branch directly hits target.
## Final solution:
##   - Deflector (5,1) [steps 0 UP→RIGHT] cursor → TeleporterA (8,1) → exit at
##     player-placed Teleporter (best at (12,1)) RIGHT → hits Target (14,1).
##   - Deflector (5,7) [steps 2 DOWN→RIGHT] → flies right past wall row (no
##     wall at y=7) → hits Target (14,7).

const ID := "l08"
const DISPLAY_NAME := "Assembly"
const HINT := "Splitter forks. Up branch needs deflector + teleporter exit; down branch needs one deflector."
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
		_pl(Vector2i(5, 4), PartData.Type.SPLITTER),
		_pl(Vector2i(8, 1), PartData.Type.TELEPORTER, 0, 0),  # pre-laid pair 0 A
		_pl(Vector2i(10, 3), PartData.Type.WALL),
		_pl(Vector2i(10, 4), PartData.Type.WALL),
		_pl(Vector2i(10, 5), PartData.Type.WALL),
		_pl(Vector2i(14, 1), PartData.Type.TARGET),
		_pl(Vector2i(14, 7), PartData.Type.TARGET),
	]
	# 3 = DEFLECTOR, 6 = TELEPORTER
	lvl.palette_types = [3, 6]
	lvl.palette_counts = [2, 1]
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
