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

@export var level_resource: LevelResource

var _pause_menu: CanvasLayer = null
var _settings_dialog: CanvasLayer = null


static func _load_level_by_id(id: String) -> LevelResource:
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
		push_error("Level: no level_resource assigned and default not found")
		return

	var err: String = LevelLoader.validate(level_resource)
	if err != "":
		push_error("Level: validation failed: " + err)
		return

	_spawned_parts = LevelLoader.populate(level_resource, _grid, _container)
	_container.add_to_group(&"cursor_container")
	_wire_hud()
	_wire_phase()
	_wire_emitters()
	_spawn_modals()


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
	elif event.is_action_pressed(&"pw_run_toggle"):
		_phase.toggle_build_run()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"pw_fullscreen"):
		var cur := DisplayServer.window_get_mode()
		if cur == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()


func _wire_hud() -> void:
	if _hud.has_method(&"set_level_title"):
		_hud.call(&"set_level_title", level_resource.display_name)
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
	# Auto-return to BUILD after a brief fail banner.
	var t := get_tree().create_timer(2.0)
	t.timeout.connect(_auto_back_to_build)


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
