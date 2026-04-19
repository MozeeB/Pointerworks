class_name Level
extends Node2D
## Level — composite root for one playable level.
##
## Wires GridSystem + PartsContainer + CursorSystem + PhaseController +
## WinChecker + HUD together. Loads a `LevelResource` (`.tres`) via
## LevelLoader on `_ready` (level_id set by SceneSwitcher prior to load).

const DEFAULT_LEVEL: String = "l01"
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")
const SETTINGS_SCENE := preload("res://scenes/ui/settings_dialog.tscn")
const LEVEL_ERROR_SCENE := preload("res://scenes/ui/level_load_error_dialog.tscn")

@export var level_resource: LevelResource

var _pause_menu: CanvasLayer = null
var _settings_dialog: CanvasLayer = null

# Undo stack: each entry is a Dictionary {op: "place"|"remove", cell, type, rotation, variant}.
const UNDO_MAX: int = 10
var _undo: Array = []
var _locked_cells: Dictionary = {}  # Vector2i → true (pre-laid parts cannot be removed)

# Touch / mouse long-press tracking for mobile parity.
# Tap = place, long-press (≥LONG_PRESS_SEC) without drag = remove.
const LONG_PRESS_SEC: float = 0.45
const LONG_PRESS_TOLERANCE_PX: float = 16.0
var _press_time_sec: float = 0.0
var _press_pos: Vector2 = Vector2.ZERO


func _show_load_error(message: String) -> void:
	var dlg := LEVEL_ERROR_SCENE.instantiate()
	add_child(dlg)
	if dlg.has_method(&"set_message"):
		dlg.call(&"set_message", message)
	dlg.back_pressed.connect(_on_back_pressed)


func _load_level_by_id(id: String) -> LevelResource:
	var gd_path := "res://data/levels/%s.gd" % id
	if ResourceLoader.exists(gd_path):
		var scr: GDScript = load(gd_path)
		if scr != null and scr.has_method(&"build"):
			var r: Variant = scr.call(&"build")
			if r is LevelResource:
				return r
	var tres_path := "res://data/levels/%s.tres" % id
	if ResourceLoader.exists(tres_path):
		return load(tres_path) as LevelResource
	return null

@onready var _grid: GridSystem = $Grid
@onready var _container: Node2D = $PartsContainer
@onready var _phase: PhaseController = $PhaseController
@onready var _win: WinChecker = $WinChecker
@onready var _fail: FailChecker = $FailChecker if has_node("FailChecker") else null
@onready var _hud: CanvasLayer = $HUD
@onready var _hover_overlay: ColorRect = $HoverOverlay if has_node("HoverOverlay") else null

var _spawned_parts: Array[Part] = []


func _ready() -> void:
	# Default if nothing supplied: consult SceneSwitcher.pending_level_id
	# (set by level_select) or fall back to DEFAULT_LEVEL. Two builder
	# paths supported:
	#   1) .gd builder   (data/levels/l01.gd  — static func build() -> LevelResource)
	#   2) .tres resource (data/levels/l01.tres)
	if level_resource == null:
		var id: String = DEFAULT_LEVEL
		var switcher := get_node_or_null(^"/root/SceneSwitcher")
		if switcher != null and switcher.get(&"pending_level_id") != null:
			var pending: String = switcher.get(&"pending_level_id")
			if pending != "":
				id = pending
		level_resource = _load_level_by_id(id)

	if level_resource == null:
		_show_load_error("Level file missing or failed to build. Try another level.")
		return

	var err: String = LevelLoader.validate(level_resource)
	if err != "":
		_show_load_error("Level is malformed: %s" % err)
		return

	_spawned_parts = LevelLoader.populate(level_resource, _grid, _container)
	for pp in level_resource.placements:
		if pp != null and pp.locked:
			_locked_cells[pp.cell] = true
	_container.add_to_group(&"cursor_container")
	# Hand the HoverOverlay material to the GridSystem so it can drive the
	# hover-ring shader uniform from the OS mouse position. Active in BUILD.
	if _hover_overlay != null and _hover_overlay.material is ShaderMaterial:
		_grid.hover_material = _hover_overlay.material
		_grid.set_hover_active(true)
	_wire_hud()
	_wire_phase()
	_wire_emitters()
	_spawn_modals()
	_configure_palette()


func _spawn_modals() -> void:
	_pause_menu = PAUSE_SCENE.instantiate()
	add_child(_pause_menu)
	_pause_menu.resume_pressed.connect(func(): pass)
	_pause_menu.restart_pressed.connect(func():
		_pause_menu.hide_menu()
		_phase.to_build()
	)
	_pause_menu.settings_pressed.connect(_open_settings)
	_pause_menu.back_pressed.connect(func():
		_pause_menu.hide_menu()
		_on_back_pressed()
	)

	_settings_dialog = SETTINGS_SCENE.instantiate()
	add_child(_settings_dialog)
	_settings_dialog.closed.connect(func(): pass)


func _open_settings() -> void:
	if _settings_dialog != null:
		_settings_dialog.call(&"open")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pw_pause"):
		if _pause_menu != null:
			_pause_menu.toggle()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pw_run_toggle"):
		_phase.toggle_build_run()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pw_fullscreen"):
		var cur := DisplayServer.window_get_mode()
		if cur == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pw_rotate"):
		_rotate_hovered_part()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pw_undo"):
		_pop_undo()
		get_viewport().set_input_as_handled()
		return
	# Number keys 1..7 select palette slots when palette active + BUILD.
	for i in 7:
		if event.is_action_pressed(&"pw_part_%d" % (i + 1)):
			var pal := _palette_node()
			if pal != null:
				pal.call(&"select_slot_by_index", i)
			get_viewport().set_input_as_handled()
			return
	# Grid clicks for place/remove during BUILD.
	# Mobile parity: left-press starts a timer; release decides:
	#   short tap (<LONG_PRESS_SEC)  → place
	#   long press (≥LONG_PRESS_SEC, didn't drag) → remove
	# Right-click still removes immediately for mouse users.
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not _phase.is_build():
			return
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_press_time_sec = Time.get_ticks_msec() / 1000.0
				_press_pos = mb.position
			else:
				var dur: float = Time.get_ticks_msec() / 1000.0 - _press_time_sec
				var moved: float = _press_pos.distance_to(mb.position)
				if moved <= LONG_PRESS_TOLERANCE_PX:
					if dur >= LONG_PRESS_SEC:
						if _try_remove_at_mouse():
							get_viewport().set_input_as_handled()
					else:
						if _try_place_at_mouse():
							get_viewport().set_input_as_handled()
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			if _try_remove_at_mouse():
				get_viewport().set_input_as_handled()


func _wire_hud() -> void:
	if _hud.has_method(&"set_level_title"):
		_hud.call(&"set_level_title", level_resource.display_name)
	if _hud.has_method(&"set_level_id"):
		_hud.call(&"set_level_id", level_resource.id)
	if _hud.has_method(&"show_hint") and level_resource.hint != "":
		_hud.call(&"show_hint", level_resource.hint, 5.0)
	if _hud.has_signal(&"run_pressed"):
		_hud.connect(&"run_pressed", _on_run_pressed)
	if _hud.has_signal(&"stop_pressed"):
		_hud.connect(&"stop_pressed", _on_stop_pressed)
	if _hud.has_signal(&"back_pressed"):
		_hud.connect(&"back_pressed", _on_back_pressed)
	if _hud.has_signal(&"next_pressed"):
		_hud.connect(&"next_pressed", _on_next_pressed)
	if _hud.has_signal(&"retry_pressed"):
		_hud.connect(&"retry_pressed", _on_retry_pressed)
	if _hud.has_signal(&"submit_on_chain_pressed"):
		_hud.connect(&"submit_on_chain_pressed", _on_submit_on_chain)
	_wire_web3()


func _wire_web3() -> void:
	var w := get_node_or_null(^"/root/Web3Bridge")
	if w == null:
		return
	w.wallet_connected.connect(func(_a): _refresh_onchain_button())
	w.wallet_disconnected.connect(func(): _refresh_onchain_button())
	w.tx_pending.connect(func(h):
		if _hud.has_method(&"set_onchain_status"):
			_hud.call(&"set_onchain_status", "tx: " + h.substr(0, 10) + "…")
	)
	w.wallet_error.connect(func(msg):
		if _hud.has_method(&"set_onchain_status"):
			_hud.call(&"set_onchain_status", "error: " + msg)
	)


func _refresh_onchain_button() -> void:
	var w := get_node_or_null(^"/root/Web3Bridge")
	if w == null or not _hud.has_method(&"set_onchain_available"):
		return
	_hud.call(&"set_onchain_available", bool(w.call(&"is_wallet_connected")))


func _configure_palette() -> void:
	var pal := _palette_node()
	if pal == null:
		return
	pal.call(&"configure", level_resource.palette_types, level_resource.palette_counts)


func _palette_node() -> Control:
	if _hud != null and _hud.has_method(&"get_palette"):
		return _hud.call(&"get_palette")
	return null


func _animate_palette_visibility(phase: int) -> void:
	var pal := _palette_node()
	if pal == null or level_resource == null:
		return
	var hint_row: Label = null
	if _hud != null and _hud.has_method(&"get_palette_hint_row"):
		hint_row = _hud.call(&"get_palette_hint_row")
	var should_show := (phase == PhaseController.Phase.BUILD) and not level_resource.palette_types.is_empty()
	if should_show:
		pal.visible = true
		var origin_y := pal.position.y
		pal.position.y = origin_y + 16
		pal.modulate.a = 0.0
		var tween := create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(pal, "modulate:a", 1.0, 0.25)
		tween.tween_property(pal, "position:y", origin_y, 0.25)
		if hint_row != null:
			hint_row.visible = true
			hint_row.modulate.a = 0.0
			tween.tween_property(hint_row, "modulate:a", 1.0, 0.4).set_delay(0.15)
	else:
		var tween := create_tween()
		tween.tween_property(pal, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): pal.visible = false)
		if hint_row != null:
			var t2 := create_tween()
			t2.tween_property(hint_row, "modulate:a", 0.0, 0.15)
			t2.tween_callback(func(): hint_row.visible = false)


func _mouse_cell() -> Vector2i:
	var world := _grid.get_global_mouse_position() - _grid.global_position
	return _grid.world_to_cell(world)


## Place-fail feedback — red square flash on the offending cell.
func _flash_cell_red(cell: Vector2i) -> void:
	if _grid == null or not _grid.is_in_bounds(cell):
		return
	var ts: float = float(GridSystem.TILE_SIZE)
	var poly := Polygon2D.new()
	var half := ts * 0.5
	poly.polygon = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half),
	])
	poly.color = AppPalette.get_color(AppPalette.Swatch.FAIL_RED)
	poly.modulate = Color(1, 1, 1, 0.7)
	poly.global_position = _grid.global_position + _grid.cell_to_world(cell)
	add_child(poly)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(poly, "modulate:a", 0.0, 0.4)
	tween.tween_property(poly, "scale", Vector2(0.92, 0.92), 0.4)
	tween.chain().tween_callback(poly.queue_free)


## Hint banner shortcut for placement messages — reuses HUD.show_hint with
## short duration so the message doesn't linger.
func _show_place_feedback(text: String, _is_ok: bool) -> void:
	if _hud != null and _hud.has_method(&"show_hint"):
		_hud.call(&"show_hint", text, 1.5)


## C1 — visual flash on the cell where a part was just placed.
## Spawns a TILE_SIZE Polygon2D, tweens scale 1.0 → 1.25 + alpha 0.8 → 0
## over 0.3 s, then queue_free.
func _flash_cell(cell: Vector2i) -> void:
	if _grid == null:
		return
	var ts: float = float(GridSystem.TILE_SIZE)
	var poly := Polygon2D.new()
	var half := ts * 0.5
	poly.polygon = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half),
	])
	poly.color = AppPalette.get_color(AppPalette.Swatch.ACCENT)
	poly.modulate = Color(1, 1, 1, 0.8)
	poly.global_position = _grid.global_position + _grid.cell_to_world(cell)
	add_child(poly)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(poly, "scale", Vector2(1.25, 1.25), 0.3)
	tween.tween_property(poly, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(poly.queue_free)


func _try_place_at_mouse() -> bool:
	var pal := _palette_node()
	if pal == null:
		return false
	var type_index: int = pal.call(&"selected")
	if type_index < 0:
		_show_place_feedback("Pick a part from the palette first.", false)
		return false
	var cell := _mouse_cell()
	if not _grid.is_in_bounds(cell):
		# Click outside grid — silent (probably user clicked HUD).
		return false
	if _grid.has_part(cell):
		_flash_cell_red(cell)
		_show_place_feedback("Cell occupied — pick an empty cell.", false)
		return false
	if not pal.call(&"consume", type_index):
		_show_place_feedback("No more of that part — try another slot.", false)
		return false
	var d := PartData.new()
	d.type = type_index
	d.rotation_steps = 0
	d.variant = 0
	var part := LevelLoader.instance_for(d)
	if part == null:
		pal.call(&"restore", type_index)
		return false
	_container.add_child(part)
	if not _grid.place_part(cell, part):
		_container.remove_child(part)
		part.queue_free()
		pal.call(&"restore", type_index)
		return false
	_spawned_parts.append(part)
	if part is Emitter:
		(part as Emitter).cursor_spawned.connect(_on_cursor_spawned)
	_flash_cell(cell)
	_push_undo({&"op": &"place", &"cell": cell, &"type": type_index, &"rotation": 0, &"variant": 0})
	return true


func _try_remove_at_mouse() -> bool:
	var cell := _mouse_cell()
	if not _grid.has_part(cell):
		return false
	if _locked_cells.has(cell):
		_flash_cell_red(cell)
		_show_place_feedback("That part is locked — pre-laid by the level.", false)
		return false  # pre-laid, not removable
	var part_node: Node = _grid.get_part_at(cell)
	if part_node == null:
		return false
	var part := part_node as Part
	if part == null:
		return false
	var type_index: int = int(part.data.type) if part.data != null else -1
	var rot: int = part.data.rotation_steps if part.data != null else 0
	var variant: int = part.data.variant if part.data != null else 0
	_grid.remove_part(cell)
	_spawned_parts.erase(part)
	var tween := part.play_remove_shrink()
	tween.tween_callback(part.queue_free)
	var pal := _palette_node()
	if pal != null and type_index >= 0:
		pal.call(&"restore", type_index)
	_push_undo({&"op": &"remove", &"cell": cell, &"type": type_index, &"rotation": rot, &"variant": variant})
	return true


func _rotate_hovered_part() -> void:
	var cell := _mouse_cell()
	if not _grid.has_part(cell):
		return
	if _locked_cells.has(cell):
		return
	var p := _grid.get_part_at(cell) as Part
	if p == null:
		return
	p.rotate_cw()


func _push_undo(entry: Dictionary) -> void:
	_undo.append(entry)
	if _undo.size() > UNDO_MAX:
		_undo.remove_at(0)


func _pop_undo() -> void:
	if _undo.is_empty():
		return
	var entry: Dictionary = _undo.pop_back()
	var cell: Vector2i = entry.get(&"cell")
	var op: StringName = entry.get(&"op")
	var pal := _palette_node()
	if op == &"place":
		# Undo a placement → remove it + restore palette count.
		if _grid.has_part(cell):
			var part := _grid.get_part_at(cell) as Part
			_grid.remove_part(cell)
			_spawned_parts.erase(part)
			if part != null:
				var t := part.play_remove_shrink()
				t.tween_callback(part.queue_free)
			if pal != null:
				pal.call(&"restore", int(entry.get(&"type", 0)))
	elif op == &"remove":
		# Undo a remove → re-spawn the part + consume palette count.
		var d := PartData.new()
		d.type = int(entry.get(&"type", 0))
		d.rotation_steps = int(entry.get(&"rotation", 0))
		d.variant = int(entry.get(&"variant", 0))
		var part := LevelLoader.instance_for(d)
		if part == null:
			return
		_container.add_child(part)
		if not _grid.place_part(cell, part):
			part.queue_free()
			return
		_spawned_parts.append(part)
		if part is Emitter:
			(part as Emitter).cursor_spawned.connect(_on_cursor_spawned)
		_flash_cell(cell)
		if pal != null:
			pal.call(&"consume", d.type)


func _on_submit_on_chain() -> void:
	var w := get_node_or_null(^"/root/Web3Bridge")
	if w == null or level_resource == null:
		return
	var level_index: int = _level_index_from_id(level_resource.id)
	if level_index < 0:
		return
	var hash: String = _solution_hash_hex()
	w.call(&"complete_level", level_index, hash)


func _level_index_from_id(id: String) -> int:
	if not id.begins_with("l"):
		return -1
	var n := int(id.substr(1)) - 1
	if n < 0 or n > 9:
		return -1
	return n


## 32-byte deterministic solution hash. For now derived from level id +
## placements; Day 6 hardening can include the real RNG seed.
func _solution_hash_hex() -> String:
	var buf: String = level_resource.id
	for pp in level_resource.placements:
		if pp == null or pp.data == null:
			continue
		buf += "|%d,%d,%d,%d,%d" % [pp.cell.x, pp.cell.y, int(pp.data.type), pp.data.rotation_steps, pp.data.variant]
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(buf.to_utf8_buffer())
	var bytes: PackedByteArray = ctx.finish()
	return "0x" + bytes.hex_encode()


func _wire_phase() -> void:
	_phase.phase_changed.connect(_on_phase_changed)
	_win.level_complete.connect(_on_level_complete)
	if _fail != null:
		_fail.level_failed.connect(_on_level_failed)


func _wire_emitters() -> void:
	for p in _spawned_parts:
		if p is Emitter:
			(p as Emitter).cursor_spawned.connect(_on_cursor_spawned)


func _on_cursor_spawned(_cursor: VirtualCursor) -> void:
	_win.record_cursor_spawn()


func _on_phase_changed(phase: int) -> void:
	if _hud.has_method(&"set_phase"):
		_hud.call(&"set_phase", phase)
	_animate_palette_visibility(phase)
	match phase:
		PhaseController.Phase.BUILD:
			_despawn_live_cursors()
			_reset_targets()
			_win.disarm()
			if _fail != null:
				_fail.disarm()
			_grid.set_hover_active(true)
		PhaseController.Phase.RUN:
			_win.arm()
			if _fail != null:
				_fail.arm()
			_grid.set_hover_active(false)
		PhaseController.Phase.WIN:
			_despawn_live_cursors()
			if _fail != null:
				_fail.disarm()
			_grid.set_hover_active(false)
		PhaseController.Phase.FAIL:
			_despawn_live_cursors()
			if _fail != null:
				_fail.disarm()
			_grid.set_hover_active(false)


func _on_run_pressed() -> void:
	_phase.to_run()


func _on_stop_pressed() -> void:
	_phase.to_build()


func _on_back_pressed() -> void:
	var switcher := get_node_or_null(^"/root/SceneSwitcher")
	if switcher != null and switcher.has_method(&"to_level_select"):
		switcher.call(&"to_level_select")


func _on_next_pressed() -> void:
	var switcher := get_node_or_null(^"/root/SceneSwitcher")
	if switcher == null or level_resource == null:
		_on_back_pressed()
		return
	var next_id: String = switcher.call(&"next_level_id", level_resource.id)
	if next_id == "":
		_on_back_pressed()
		return
	switcher.call(&"to_level", next_id)


func _on_retry_pressed() -> void:
	_phase.to_build()


func _on_level_failed(missed_targets: int) -> void:
	_phase.to_fail()
	if _hud.has_method(&"show_fail"):
		_hud.call(&"show_fail", missed_targets)
	_play_screen_shake()
	_play_fail_red_breathe()
	# Auto-return to BUILD after a brief fail banner.
	var t := get_tree().create_timer(2.0)
	t.timeout.connect(_auto_back_to_build)


## C4 — short red modulate dwell so the fail registers visually.
## 0.0 → 0.25 (red tint) → 0.0 over 0.6 s. Doesn't block input — pause/back
## still respond, and screen shake runs in parallel.
func _play_fail_red_breathe() -> void:
	var red := AppPalette.get_color(AppPalette.Swatch.FAIL_RED)
	var tinted := Color(red.r, red.g, red.b, 0.25)
	var clear := Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", clear.lerp(tinted, 1.0), 0.2)
	tween.tween_property(self, "modulate", clear, 0.4)


## 4-kick screen shake (~0.4 s). Shifts Level.offset via Tween; no camera.
func _play_screen_shake() -> void:
	var original := position
	var tween := create_tween()
	for kick in 6:
		var dx := randf_range(-6.0, 6.0)
		var dy := randf_range(-6.0, 6.0)
		tween.tween_property(self, "position", original + Vector2(dx, dy), 0.04)
	tween.tween_property(self, "position", original, 0.06)


func _auto_back_to_build() -> void:
	# Safe: only pivot if we're still on the FAIL screen.
	if _phase.is_fail():
		_phase.to_build()
		if _hud.has_method(&"hide_fail"):
			_hud.call(&"hide_fail")


func _on_level_complete(cursors_used: int) -> void:
	_phase.to_win()
	var progress := get_node_or_null(^"/root/Progress")
	# Capture previous best BEFORE mark_completed overwrites it — lets the
	# HUD show a "🏆 new best!" stamp when applicable.
	var prev_best: int = -1
	if progress != null and progress.has_method(&"cursors_used_for"):
		prev_best = int(progress.call(&"cursors_used_for", level_resource.id))
	if progress != null and progress.has_method(&"mark_completed"):
		progress.call(&"mark_completed", level_resource.id, cursors_used)
	if _hud.has_method(&"set_prev_best_hint"):
		_hud.call(&"set_prev_best_hint", prev_best)
	if _hud.has_method(&"show_win"):
		_hud.call(&"show_win", cursors_used, level_resource.par_cursors)
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null and audio.has_method(&"play_sfx"):
		audio.call(&"play_sfx", &"win")
	_refresh_onchain_button()


func _despawn_live_cursors() -> void:
	for c in get_tree().get_nodes_in_group(&"virtual_cursors"):
		var vc := c as VirtualCursor
		if vc != null and vc.is_alive():
			vc.die(&"phase_reset")


func _reset_targets() -> void:
	# Idempotent reset — flips each Target's _hit state without tree churn.
	# Uses the `targets` group as source of truth (covers targets placed from
	# the palette mid-session as well as pre-laid ones — previously we only
	# iterated `_spawned_parts`, which caused a stuck _hit=true state if a
	# target got added/removed outside the array. That manifested as "hit
	# the target but level never completes".
	for n in get_tree().get_nodes_in_group(&"targets"):
		var t := n as Target
		if is_instance_valid(t):
			t.reset()
