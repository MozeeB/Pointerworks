class_name Level
extends Node2D
## Level — composite root for one playable level.
##
## Wires GridSystem + PartsContainer + CursorSystem + PhaseController +
## WinChecker + HUD together. Loads a `LevelResource` (`.tres`) via
## LevelLoader on `_ready` (level_id set by SceneSwitcher prior to load).

const DEFAULT_LEVEL: String = "l01"

@export var level_resource: LevelResource


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


func _wire_phase() -> void:
	_phase.phase_changed.connect(_on_phase_changed)
	_win.level_complete.connect(_on_level_complete)


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
		PhaseController.Phase.RUN:
			_win.arm()
		PhaseController.Phase.WIN:
			_despawn_live_cursors()
		PhaseController.Phase.FAIL:
			_despawn_live_cursors()


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


func _on_level_complete(cursors_used: int) -> void:
	_phase.to_win()
	var progress := get_node_or_null(^"/root/Progress")
	if progress != null and progress.has_method(&"mark_completed"):
		progress.call(&"mark_completed", level_resource.id, cursors_used)
	if _hud.has_method(&"show_win"):
		_hud.call(&"show_win", cursors_used, level_resource.par_cursors)


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
