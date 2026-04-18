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
var _idle_tween: Tween = null


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
	# Subscribe to phase changes so we can pause idle pulse during RUN.
	var phase_node := get_tree().root.find_child(&"PhaseController", true, false)
	if phase_node != null and phase_node.has_signal(&"phase_changed"):
		phase_node.phase_changed.connect(_on_phase_changed)
	_start_idle_pulse()


## Subtle breathing — modulate.a 0.85 ↔ 1.0 + scale 1.0 ↔ 1.06 over 1.2 s.
## Cues "this thing is interactive" without screaming.
func _start_idle_pulse() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
	_idle_tween = create_tween().set_loops()
	_idle_tween.set_parallel(true)
	_idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(self, "modulate:a", 0.85, 0.6)
	_idle_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.6)
	_idle_tween.chain()
	_idle_tween.tween_property(self, "modulate:a", 1.0, 0.6)
	_idle_tween.tween_property(self, "scale", Vector2.ONE, 0.6)


func _stop_idle_pulse() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null
	modulate.a = 1.0
	scale = Vector2.ONE


func _on_phase_changed(phase: int) -> void:
	# Idle pulse only in BUILD; cursors take over visual energy in RUN.
	if phase == 0:  # PhaseController.Phase.BUILD
		_start_idle_pulse()
	else:
		_stop_idle_pulse()


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
	_birth_flash()
	var audio := _audio_bus()
	if audio != null:
		audio.play_sfx(&"spawn")


## C3 — small ring flash at the emitter when each cursor is born.
## Magenta (cursor color) so player traces the spawn point easily.
func _birth_flash() -> void:
	var ring := Polygon2D.new()
	# Approximate a ring with 12-sided polygon outline using a thin annulus.
	var pts := PackedVector2Array()
	for i in 12:
		var a := (float(i) / 12.0) * TAU
		pts.append(Vector2.RIGHT.rotated(a) * 4.0)
	ring.polygon = pts
	ring.color = AppPalette.get_color(AppPalette.Swatch.CURSOR_MAGENTA)
	ring.modulate = Color(1, 1, 1, 1)
	get_parent().add_child(ring)
	ring.global_position = global_position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "scale", Vector2(5.0, 5.0), 0.25)
	tween.tween_property(ring, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(ring.queue_free)


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
