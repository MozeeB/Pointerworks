extends Node
## Progress — persistent player progress.
##
## Stores completed levels + tutorial flag in a ConfigFile at
## `user://save.cfg`. On web, this is backed by localStorage under
## the key `userdata/_Pointerworks/save.cfg`.
##
## Save schema version: 1. Bump on breaking changes + add migration.

signal progress_changed

const SAVE_PATH := "user://save.cfg"
const CURRENT_VERSION := 1

var seen_tutorial: bool = false
var _completed: PackedStringArray = PackedStringArray()
var _cursors_used: Dictionary = {}  # level_id (String) → cursors_used (int)


func _ready() -> void:
	load_progress()


func load_progress() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		# File doesn't exist yet or was corrupted. Defaults already set.
		# On corruption vs. missing, we don't distinguish for MVP — just reset.
		_reset_to_defaults()
		return
	var version: int = cfg.get_value("meta", "version", 0)
	if version != CURRENT_VERSION:
		push_warning("Progress: save version mismatch (got %d, expected %d). Resetting." % [version, CURRENT_VERSION])
		_reset_to_defaults()
		return
	seen_tutorial = cfg.get_value("state", "seen_tutorial", false)
	var completed_raw: Array = cfg.get_value("state", "completed", [])
	_completed = PackedStringArray(completed_raw)
	_cursors_used = cfg.get_value("state", "cursors_used", {})


func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", CURRENT_VERSION)
	cfg.set_value("state", "seen_tutorial", seen_tutorial)
	cfg.set_value("state", "completed", Array(_completed))
	cfg.set_value("state", "cursors_used", _cursors_used)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_error("Progress: failed to save (err=%d)" % err)


func mark_completed(level_id: String, cursors_used: int) -> void:
	if not is_completed(level_id):
		_completed.append(level_id)
	# Keep the best (lowest) cursors_used value — favour optimal play.
	var prev: int = _cursors_used.get(level_id, 1 << 30)
	if cursors_used < prev:
		_cursors_used[level_id] = cursors_used
	save_progress()
	progress_changed.emit()


func is_completed(level_id: String) -> bool:
	return _completed.has(level_id)


func is_unlocked(level_id: String) -> bool:
	# Level 1 always unlocked; 2..N unlock when previous is completed.
	if level_id == "l01":
		return true
	if not level_id.begins_with("l"):
		return false
	var n := int(level_id.substr(1))
	if n <= 1:
		return true
	return is_completed("l%02d" % (n - 1))


func cursors_used_for(level_id: String) -> int:
	return _cursors_used.get(level_id, -1)


func set_tutorial_seen() -> void:
	if seen_tutorial:
		return
	seen_tutorial = true
	save_progress()


func _reset_to_defaults() -> void:
	seen_tutorial = false
	_completed = PackedStringArray()
	_cursors_used = {}
	progress_changed.emit()
