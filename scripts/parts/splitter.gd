class_name Splitter
extends Part
## Splitter — consumes the incoming cursor, spawns two new cursors
## with velocities perpendicular to the input.
##
## Max-cursor safety: if the global live-cursor count exceeds
## `MAX_LIVE_CURSORS`, the oldest cursor is killed before spawning to
## prevent splitter fork bombs.

const MAX_LIVE_CURSORS := 64
const VIRTUAL_CURSOR_SCENE := preload("res://scenes/level/virtual_cursor.tscn")


func _ready() -> void:
	super()


func apply_to_cursor(cursor: VirtualCursor) -> void:
	if not cursor.is_alive():
		return
	var parent_node: Node = cursor.get_parent()
	if parent_node == null:
		return

	var base_velocity: Vector2 = cursor.velocity
	var grid_rect: Rect2 = cursor.grid_rect
	var speed: float = base_velocity.length()
	if speed <= 0.001:
		cursor.die(&"splitter_no_velocity")
		return

	# Two outputs: +90° CW and -90° CW from the input direction.
	var dir_a: Vector2 = base_velocity.rotated(PI * 0.5).normalized() * speed
	var dir_b: Vector2 = base_velocity.rotated(-PI * 0.5).normalized() * speed

	# Consume the input cursor first to keep net count stable (1 in, 2 out = +1).
	cursor.die(&"split")

	_enforce_global_cap()
	_spawn_child(parent_node, dir_a, grid_rect)
	_spawn_child(parent_node, dir_b, grid_rect)


func _spawn_child(parent_node: Node, velocity: Vector2, grid_rect: Rect2) -> void:
	var child := VIRTUAL_CURSOR_SCENE.instantiate() as VirtualCursor
	# Offset slightly in the child's direction so it doesn't immediately
	# re-overlap the splitter's Area2D (fork-bomb avoidance).
	const SPAWN_OFFSET := 36.0  # just outside the 48×48 splitter shape
	child.global_position = global_position + velocity.normalized() * SPAWN_OFFSET
	child.velocity = velocity
	child.grid_rect = grid_rect
	parent_node.add_child(child)


func _enforce_global_cap() -> void:
	var live := get_tree().get_nodes_in_group(&"virtual_cursors")
	if live.size() < MAX_LIVE_CURSORS:
		return
	# Kill the oldest live cursor (first in group).
	for node in live:
		var vc := node as VirtualCursor
		if vc != null and vc.is_alive():
			vc.die(&"cursor_cap")
			return
