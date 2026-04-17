extends RefCounted
## L04 Refinery — introduces the palette. Player places the Splitter
## and both Deflectors to route a single emit into both targets.
##
## Pre-laid: emitter + 2 targets. Palette: 1 splitter + 2 deflectors
## (exact count — no over-allocation). Click a palette slot, click the
## grid to place. Right-click a placed part to remove. R rotates the
## hovered part. Ctrl+Z (Z) undoes the last place/remove.

const ID := "l04"
const DISPLAY_NAME := "Refinery"
const HINT := "Place the splitter + deflectors. Click a palette slot, click the grid."
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
		_pl(Vector2i(14, 1), PartData.Type.TARGET),
		_pl(Vector2i(14, 7), PartData.Type.TARGET),
	]
	# Palette — type ids match PartData.Type enum ordering.
	# 3 = DEFLECTOR, 4 = SPLITTER
	lvl.palette_types = [4, 3]
	lvl.palette_counts = [1, 2]  # 1 splitter, 2 deflectors; exact solve
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
