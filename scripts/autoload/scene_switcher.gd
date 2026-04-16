extends Node
## SceneSwitcher — central scene transition helper.
##
## Keeps scene-change logic in one place so callers don't sprinkle
## `get_tree().change_scene_to_file()` across the codebase.

signal scene_changing(path: String)
signal scene_changed(path: String)

const MAIN_MENU_PATH := "res://scenes/main.tscn"
const LEVEL_SELECT_PATH := "res://scenes/ui/level_select.tscn"
const LEVEL_PATH := "res://scenes/level/level.tscn"

## Pending level id consumed by `Level._ready` on the next transition.
var pending_level_id: String = "l01"


func to_main_menu() -> void:
	_change(MAIN_MENU_PATH)


func to_level_select() -> void:
	_change(LEVEL_SELECT_PATH)


func to_level(level_id: String) -> void:
	# Stash id so Level._ready can pick up via autoload reference.
	pending_level_id = level_id
	_change(LEVEL_PATH)


func next_level_id(current: String) -> String:
	# "l03" → "l04". Returns "" if already at l10.
	if not current.begins_with("l"):
		return ""
	var n := int(current.substr(1))
	if n < 1 or n >= 10:
		return ""
	return "l%02d" % (n + 1)


func _change(path: String) -> void:
	scene_changing.emit(path)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneSwitcher: failed to change scene to %s (err=%d)" % [path, err])
		return
	scene_changed.emit(path)
