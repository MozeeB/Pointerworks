class_name GridSystem
extends Node2D
## GridSystem — authoritative grid state for a level.
##
## Maps `Vector2i` cell coords → Part `Node` instance. All placement / removal
## goes through here so `part_placed` / `part_removed` signals fire consistently.
## Never mutate the dictionary from outside — call `place_part` / `remove_part`.

const TILE_SIZE := 64
const DEFAULT_GRID_SIZE := Vector2i(16, 10)  # 1024×640 playfield inside 1280×720

signal part_placed(cell: Vector2i, part: Node)
signal part_removed(cell: Vector2i, part: Node)

@export var grid_size: Vector2i = DEFAULT_GRID_SIZE

# Dictionary<Vector2i, Node>. Godot 4.6 supports typed dicts but plain Dict is
# fine here — values are all Part-derived nodes.
var _cells: Dictionary = {}


## Optional ShaderMaterial whose `hover_cell` uniform tracks mouse hover.
## Wired by Level._ready by passing the HoverOverlay material here.
var hover_material: ShaderMaterial = null
var _hover_active: bool = false


func _ready() -> void:
	add_to_group(&"grid_system")
	set_process(true)


func set_hover_active(active: bool) -> void:
	_hover_active = active
	if hover_material != null:
		# Sync grid_origin so the shader always tracks the actual node position.
		# Do this both on activate and deactivate to catch any deferred-position
		# setups (e.g. the node moves after _ready).
		hover_material.set_shader_parameter(&"grid_origin", Vector2(global_position))
		if not active:
			hover_material.set_shader_parameter(&"hover_cell", Vector2(-1, -1))


func _process(_delta: float) -> void:
	if not _hover_active or hover_material == null:
		return
	# Keep grid_origin in sync with the node's actual canvas position each frame.
	hover_material.set_shader_parameter(&"grid_origin", Vector2(global_position))
	var world := get_global_mouse_position() - global_position
	var cell := world_to_cell(world)
	if not is_in_bounds(cell):
		hover_material.set_shader_parameter(&"hover_cell", Vector2(-1, -1))
		return
	hover_material.set_shader_parameter(&"hover_cell", Vector2(cell.x, cell.y))


func world_to_cell(world: Vector2) -> Vector2i:
	return Vector2i(floori(world.x / TILE_SIZE), floori(world.y / TILE_SIZE))


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE + TILE_SIZE * 0.5, cell.y * TILE_SIZE + TILE_SIZE * 0.5)


func snap(world: Vector2) -> Vector2:
	return cell_to_world(world_to_cell(world))


func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y


func has_part(cell: Vector2i) -> bool:
	return _cells.has(cell)


func get_part_at(cell: Vector2i) -> Node:
	return _cells.get(cell, null)


func place_part(cell: Vector2i, part: Node) -> bool:
	if not is_in_bounds(cell):
		return false
	if _cells.has(cell):
		return false
	_cells[cell] = part
	if part is Node2D:
		(part as Node2D).position = cell_to_world(cell)
	if part.has_method(&"set_cell"):
		part.call(&"set_cell", cell)
	part_placed.emit(cell, part)
	return true


func remove_part(cell: Vector2i) -> Node:
	if not _cells.has(cell):
		return null
	var part: Node = _cells[cell]
	_cells.erase(cell)
	part_removed.emit(cell, part)
	return part


func clear() -> void:
	for cell in _cells.keys().duplicate():
		var part: Node = _cells[cell]
		_cells.erase(cell)
		part_removed.emit(cell, part)


func get_all_parts() -> Array:
	return _cells.values().duplicate()


func get_grid_rect_world() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(grid_size.x * TILE_SIZE, grid_size.y * TILE_SIZE))
