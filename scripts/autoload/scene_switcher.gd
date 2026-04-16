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


func to_main_menu() -> void:
	_change(MAIN_MENU_PATH)


func to_level_select() -> void:
	_change(LEVEL_SELECT_PATH)


func to_level(_level_id: int) -> void:
	# Level ID is loaded by the Level scene from a context set on the tree
	# (implemented Day 2 when LevelLoader + LevelResource land).
	_change(LEVEL_PATH)


func _change(path: String) -> void:
	scene_changing.emit(path)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneSwitcher: failed to change scene to %s (err=%d)" % [path, err])
		return
	scene_changed.emit(path)
