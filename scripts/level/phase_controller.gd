class_name PhaseController
extends Node
## PhaseController — FSM for an in-level session.
##
## BUILD  → player drags parts onto grid.
## RUN    → sim active, virtual cursors can spawn.
## WIN    → all targets hit.
## FAIL   → all cursors dead with ≥1 target unhit (Day 4 FailChecker emits).
##
## Transitions are guarded — callers can request a transition but the
## controller rejects invalid ones.

enum Phase { BUILD, RUN, WIN, FAIL }

signal phase_changed(phase: Phase)

var _phase: Phase = Phase.BUILD


func get_phase() -> Phase:
	return _phase


func is_build() -> bool: return _phase == Phase.BUILD
func is_run() -> bool:   return _phase == Phase.RUN
func is_win() -> bool:   return _phase == Phase.WIN
func is_fail() -> bool:  return _phase == Phase.FAIL


func to_build() -> bool:
	# Valid from RUN (cancel), FAIL (retry), WIN (re-edit — rare).
	return _set_phase(Phase.BUILD)


func to_run() -> bool:
	if _phase != Phase.BUILD:
		return false
	return _set_phase(Phase.RUN)


func to_win() -> bool:
	if _phase != Phase.RUN:
		return false
	return _set_phase(Phase.WIN)


func to_fail() -> bool:
	if _phase != Phase.RUN:
		return false
	return _set_phase(Phase.FAIL)


func toggle_build_run() -> void:
	if _phase == Phase.BUILD:
		to_run()
	elif _phase == Phase.RUN:
		to_build()


func _set_phase(next: Phase) -> bool:
	if _phase == next:
		return false
	_phase = next
	phase_changed.emit(next)
	return true
