class_name FailChecker
extends Node
## FailChecker — emits `level_failed` when every virtual cursor has died
## while one or more targets remain unhit.
##
## Armed on BUILD → RUN. Disarmed on any transition. Requires at least
## one cursor to have lived (prevents firing on the very first RUN tick
## before any emitter can spawn).

signal level_failed(missed_targets: int)

var _enabled: bool = false
var _had_cursor: bool = false
var _grace_ticks: int = 0


func arm() -> void:
	_enabled = true
	_had_cursor = false
	_grace_ticks = 6  # ~0.1 s at 60 Hz; covers the first tick after Run press


func disarm() -> void:
	_enabled = false


func _physics_process(_delta: float) -> void:
	if not _enabled:
		return
	if _grace_ticks > 0:
		_grace_ticks -= 1
		return
	var live := get_tree().get_nodes_in_group(&"virtual_cursors").size()
	if live > 0:
		_had_cursor = true
		return
	if not _had_cursor:
		return
	# All cursors dead. Check targets.
	var unhit := 0
	for n in get_tree().get_nodes_in_group(&"targets"):
		var t := n as Target
		if t == null:
			continue
		if not t.is_hit():
			unhit += 1
	if unhit > 0:
		_enabled = false
		level_failed.emit(unhit)
