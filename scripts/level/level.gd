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
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and _phase.is_build():
			if mb.button_index == MOUSE_BUTTON_LEFT:
				if _try_place_at_mouse():
					get_viewport().set_input_as_handled()
			elif mb.button_index == MOUSE_BUTTON_RIGHT:
				if _try_remove_at_mouse():
					get_viewport().set_input_as_handled()


func _wire_hud() -> void:
	if _hud.has_method(&"set_level_title"):
		_hud.call(&"set_level_title", level_resource.display_name)
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


func _mouse_cell() -> Vector2i:
	var world := _grid.get_global_mouse_position() - _grid.global_position
	return _grid.world_to_cell(world)


func _try_place_at_mouse() -> bool:
	var pal := _palette_node()
	if pal == null:
		return false
	var type_index: int = pal.call(&"selected")
	if type_index < 0:
		return false
	var cell := _mouse_cell()
	if not _grid.is_in_bounds(cell):
		return false
	if _grid.has_part(cell):
		return false
	if not pal.call(&"consume", type_index):
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
	_push_undo({&"op": &"place", &"cell": cell, &"type": type_index, &"rotation": 0, &"variant": 0})
	return true


func _try_remove_at_mouse() -> bool:
	var cell := _mouse_cell()
	if not _grid.has_part(cell):
		return false
	if _locked_cells.has(cell):
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
	var pal := _palette_node()
	if pal != null and level_resource != null:
		pal.visible = (phase == PhaseController.Phase.BUILD) and not level_resource.palette_types.is_empty()
	match phase:
		PhaseController.Phase.BUILD:
			_despawn_live_cursors()
			_reset_targets()
			_win.disarm()
			if _fail != null:
				_fail.disarm()
		PhaseController.Phase.RUN:
			_win.arm()
			if _fail != null:
				_fail.arm()
		PhaseController.Phase.WIN:
			_despawn_live_cursors()
			if _fail != null:
				_fail.disarm()
		PhaseController.Phase.FAIL:
			_despawn_live_cursors()
			if _fail != null:
				_fail.disarm()


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
	# Auto-return to BUILD after a brief fail banner.
	var t := get_tree().create_timer(2.0)
	t.timeout.connect(_auto_back_to_build)


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
	if progress != null and progress.has_method(&"mark_completed"):
		progress.call(&"mark_completed", level_resource.id, cursors_used)
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
	for p in _spawned_parts:
		if is_instance_valid(p) and p is Target:
			(p as Target).reset()
