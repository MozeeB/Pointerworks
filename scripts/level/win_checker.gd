class_name WinChecker
extends Node
## WinChecker — emits `level_complete` when every Target in `targets` group is hit.
##
## Subscribe in `Level._ready()`; pass the cursor-count signal from wherever
## spawns/counts happen so we can report `cursors_used` at the win moment.

signal level_complete(cursors_used: int)

var _cursors_used: int = 0
var _targets: Array[Target] = []
var _enabled: bool = false


func arm() -> void:
	# Called when the level transitions BUILD → RUN.
	_cursors_used = 0
	_enabled = true
	_targets.clear()
	for n in get_tree().get_nodes_in_group(&"targets"):
		var t := n as Target
		if t == null:
			continue
		_targets.append(t)
		if not t.hit.is_connected(_on_target_hit):
			t.hit.connect(_on_target_hit)


func disarm() -> void:
	_enabled = false


func record_cursor_spawn() -> void:
	if _enabled:
		_cursors_used += 1


func _on_target_hit() -> void:
	if not _enabled:
		return
	if _all_hit():
		_enabled = false
		level_complete.emit(_cursors_used)


func _all_hit() -> bool:
	for t in _targets:
		if not t.is_hit():
			return false
	return true
