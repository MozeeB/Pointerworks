class_name LevelLoader
extends RefCounted
## LevelLoader — turns a `LevelResource` into runtime Part instances
## placed inside a `GridSystem` + `PartsContainer` pair.
##
## Separated from `Level.gd` so future unit-tests can load a .tres
## without a full scene tree. Static-only — no state.
##
## Scene mapping by `PartData.Type` enum:
##   EMITTER    → scenes/parts/emitter.tscn
##   WALL       → scenes/parts/wall.tscn
##   TARGET     → scenes/parts/target.tscn
##   DEFLECTOR  → scenes/parts/deflector.tscn
##   SPLITTER   → scenes/parts/splitter.tscn
##   SPEED_MOD  → scenes/parts/speed_mod.tscn
##   TELEPORTER → scenes/parts/teleporter.tscn

const PART_SCENES: Dictionary = {
	PartData.Type.EMITTER: preload("res://scenes/parts/emitter.tscn"),
	PartData.Type.WALL: preload("res://scenes/parts/wall.tscn"),
	PartData.Type.TARGET: preload("res://scenes/parts/target.tscn"),
	PartData.Type.DEFLECTOR: preload("res://scenes/parts/deflector.tscn"),
	PartData.Type.SPLITTER: preload("res://scenes/parts/splitter.tscn"),
	PartData.Type.SPEED_MOD: preload("res://scenes/parts/speed_mod.tscn"),
	PartData.Type.TELEPORTER: preload("res://scenes/parts/teleporter.tscn"),
}


static func instance_for(data: PartData) -> Part:
	if data == null:
		return null
	var scene: PackedScene = PART_SCENES.get(data.type, null)
	if scene == null:
		push_error("LevelLoader: no scene for PartData.Type %s" % data.type)
		return null
	var inst := scene.instantiate() as Part
	if inst == null:
		push_error("LevelLoader: instantiated part is not a Part subclass")
		return null
	inst.data = data
	return inst


static func validate(level: LevelResource) -> String:
	# Returns "" if OK, else a human-readable error.
	if level == null:
		return "null level"
	if level.grid_size.x <= 0 or level.grid_size.y <= 0:
		return "invalid grid_size %s" % str(level.grid_size)

	# Teleporter pair integrity.
	var pair_counts: Dictionary = {}
	for p in level.placements:
		if p == null or p.data == null:
			continue
		if p.data.type == PartData.Type.TELEPORTER:
			var id: int = p.data.variant
			pair_counts[id] = int(pair_counts.get(id, 0)) + 1
	for id in pair_counts:
		if int(pair_counts[id]) != 2:
			return "teleporter pair_id %d has %d endpoints (need exactly 2)" % [id, pair_counts[id]]

	# At least one emitter + one target so the puzzle is solvable.
	var has_emitter := false
	var has_target := false
	for p in level.placements:
		if p == null or p.data == null:
			continue
		if p.data.type == PartData.Type.EMITTER: has_emitter = true
		if p.data.type == PartData.Type.TARGET: has_target = true
	if not has_emitter:
		return "no emitter in placements"
	if not has_target:
		return "no target in placements"

	return ""


static func populate(level: LevelResource, grid: GridSystem, container: Node) -> Array[Part]:
	# Instantiate every placement and add to container via grid.place_part.
	# Returns the list of instantiated Parts (for cleanup on level-switch).
	var result: Array[Part] = []
	if level == null or grid == null or container == null:
		return result
	grid.grid_size = level.grid_size
	for p in level.placements:
		if p == null:
			continue
		var part := instance_for(p.data)
		if part == null:
			continue
		container.add_child(part)
		if not grid.place_part(p.cell, part):
			# Collision or out-of-bounds — remove to avoid orphan.
			container.remove_child(part)
			part.queue_free()
			continue
		result.append(part)
	return result
