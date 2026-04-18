class_name Emitter
extends Part
## Emitter — spawns a VirtualCursor whenever the real OS cursor enters it.
##
## Cooldown: prevents fork-bomb when user hovers still. Re-arms on `mouse_exited`.
## Base emit direction is +X; rotated by the part's `rotation_steps`.

const EMIT_COOLDOWN := 0.15
const VIRTUAL_CURSOR_SCENE := preload("res://scenes/level/virtual_cursor.tscn")

signal cursor_spawned(cursor: VirtualCursor)

@export var base_direction: Vector2 = Vector2.RIGHT

var _mouse_over: bool = false
var _cooldown: float = 0.0


func _ready() -> void:
	super()
	mouse_entered.connect(_on_real_mouse_enter)
	mouse_exited.connect(_on_real_mouse_exit)
	# Also listen for direct input on the Area2D — clicking the emitter
	# spawns a single cursor immediately. More discoverable than hover-only,
	# and a hard backstop for any browser where Area2D mouse_entered is
	# unreliable (some embedded webviews + automated test harnesses).
	input_event.connect(_on_input_event)
	_apply_palette()
	var s := get_node_or_null(^"/root/Settings")
	if s != null:
		s.settings_changed.connect(_apply_palette)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_spawn_cursor()
			# Also flip the hover state so subsequent hover keeps emitting.
			_mouse_over = true
			_cooldown = EMIT_COOLDOWN


func _apply_palette() -> void:
	# Re-color the amber body when colorblind toggles.
	if has_node("Body"):
		var body: Polygon2D = $Body
		body.color = AppPalette.get_color(AppPalette.Swatch.EMITTER_AMBER)


func _process(delta: float) -> void:
	if not _mouse_over:
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = EMIT_COOLDOWN
		_spawn_cursor()


func on_real_mouse_enter() -> void:
	_mouse_over = true
	_cooldown = 0.0  # spawn immediately on enter


func on_real_mouse_exit() -> void:
	_mouse_over = false


func _on_real_mouse_enter() -> void:
	on_real_mouse_enter()


func _on_real_mouse_exit() -> void:
	on_real_mouse_exit()


## Emitter does not affect cursors that pass through it (avoids self-retrigger loops).
func apply_to_cursor(_cursor: VirtualCursor) -> void:
	pass


func _spawn_cursor() -> void:
	var cursor := VIRTUAL_CURSOR_SCENE.instantiate() as VirtualCursor
	cursor.velocity = direction_rotated(base_direction).normalized() * VirtualCursor.DEFAULT_SPEED
	# Inherit the grid_rect of the nearest GridSystem, if any.
	var grid := _find_grid_system()
	if grid != null:
		var gr := grid.get_grid_rect_world()
		# Convert to world by adding the grid node's global position.
		cursor.grid_rect = Rect2(grid.global_position + gr.position, gr.size)
	# IMPORTANT: add_child BEFORE setting global_position. Otherwise the
	# pre-parent assignment is treated as the local Vector2 and re-parenting
	# under PartsContainer offsets the cursor by the container's transform.
	_cursor_container().add_child(cursor)
	cursor.global_position = global_position
	cursor_spawned.emit(cursor)
	var audio := _audio_bus()
	if audio != null:
		audio.play_sfx(&"spawn")


func _find_grid_system() -> GridSystem:
	var nodes := get_tree().get_nodes_in_group(&"grid_system")
	if nodes.is_empty():
		return null
	return nodes[0] as GridSystem


func _cursor_container() -> Node:
	# Prefer an explicit container via group; fall back to the Emitter's parent.
	var nodes := get_tree().get_nodes_in_group(&"cursor_container")
	if not nodes.is_empty():
		return nodes[0]
	return get_parent()


func _audio_bus() -> Node:
	return get_node_or_null(^"/root/AudioBus")
