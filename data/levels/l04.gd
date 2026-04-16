extends RefCounted
## L04 Refinery — fork one stream into two via Splitter.
##
## Emitter → Splitter in the middle of the grid → UP branch into a
## Deflector that turns RIGHT into Target A; DOWN branch into a
## Deflector turning RIGHT into Target B.

const ID := "l04"
const DISPLAY_NAME := "Refinery"
const HINT := "Splitter forks the stream perpendicular to input."
const PAR_CURSORS := 1  # 1 emit fires the whole network (splitter doubles internally)


static func build() -> LevelResource:
	var lvl := LevelResource.new()
	lvl.id = ID
	lvl.display_name = DISPLAY_NAME
	lvl.hint = HINT
	lvl.par_cursors = PAR_CURSORS
	lvl.grid_size = Vector2i(16, 10)
	lvl.placements = [
		_pl(Vector2i(1, 4), PartData.Type.EMITTER),
		_pl(Vector2i(7, 4), PartData.Type.SPLITTER),
		# UP branch: DOWN cursor from splitter is (0, +y). DeflectorDown rotation 2 → +PI, produces (256,0) right.
		# Wait: splitter input right (+x) → dir_a = rotated(PI/2) = (0, +y) DOWN; dir_b = (0, -y) UP.
		# UP cursor at y decreasing. DeflectorUp (steps=0, angle=PI/2) turns UP→RIGHT (0,-y).rot(PI/2)=(y,0)=(+,0) RIGHT.
		# DOWN cursor goes +y. DeflectorDown needs to turn DOWN→RIGHT. Angle needed: (0,+y)→(+x,0) = rotate by -PI/2.
		# Formula angle = PI/2 + steps*PI/2. Want 3PI/2 → steps=2 → node rot = PI.
		_pl(Vector2i(7, 1), PartData.Type.DEFLECTOR, 0),  # UP branch turns right
		_pl(Vector2i(7, 7), PartData.Type.DEFLECTOR, 2),  # DOWN branch turns right
		_pl(Vector2i(14, 1), PartData.Type.TARGET),
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
