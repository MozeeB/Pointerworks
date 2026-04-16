class_name Teleporter
extends Part
## Teleporter — paired portals. Cursor entering A despawns and a new
## cursor spawns at B with the same velocity (not reflected).
##
## Pairing: every Teleporter declares a `pair_id` (int). Exactly two
## Teleporters per level must share the same `pair_id`. LevelLoader
## (Day 6) validates this at load; at runtime the exit is found by
## scanning the `teleporters` group for the other with matching id.
##
## Anti-loop: the spawned child is offset in its velocity direction so
## it doesn't immediately re-overlap the exit portal.

const SPAWN_OFFSET := 36.0  # just past 48×48 exit shape → no re-overlap
const VIRTUAL_CURSOR_SCENE := preload("res://scenes/level/virtual_cursor.tscn")

@export var pair_id: int = 0


func _ready() -> void:
	super()
	add_to_group(&"teleporters")


func apply_to_cursor(cursor: VirtualCursor) -> void:
	if not cursor.is_alive():
		return
	# Pull pair_id override from PartData.variant if present.
	var id: int = pair_id
	if data != null:
		id = data.variant

	var exit: Teleporter = _find_pair(id)
	if exit == null:
		# Unpaired teleporter — pass-through to avoid hard-failing dev scenes.
		# LevelLoader rejects this config at load in production (Day 6).
		return

	var velocity: Vector2 = cursor.velocity
	var grid_rect: Rect2 = cursor.grid_rect
	var parent_node: Node = cursor.get_parent()
	cursor.die(&"teleport_in")
	if parent_node == null:
		return

	var child := VIRTUAL_CURSOR_SCENE.instantiate() as VirtualCursor
	child.global_position = exit.global_position + velocity.normalized() * SPAWN_OFFSET
	child.velocity = velocity
	child.grid_rect = grid_rect
	parent_node.add_child(child)
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null:
		audio.call(&"play_sfx", &"deflect")


func _find_pair(id: int) -> Teleporter:
	var nodes := get_tree().get_nodes_in_group(&"teleporters")
	for n in nodes:
		if n == self:
			continue
		var t := n as Teleporter
		if t == null:
			continue
		var other_id: int = t.pair_id
		if t.data != null:
			other_id = t.data.variant
		if other_id == id:
			return t
	return null
