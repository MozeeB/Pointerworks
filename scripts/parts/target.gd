class_name Target
extends Part
## Target — lights up the first time a VirtualCursor overlaps it.
## Subsequent cursors still die (consumed) but no re-trigger.
##
## `WinChecker` (Day 2) monitors the `targets` group and emits level-complete
## when all are hit.

signal hit

var _hit: bool = false

@onready var _inner: Polygon2D = $Inner if has_node("Inner") else null


func _ready() -> void:
	super()
	add_to_group(&"targets")


func apply_to_cursor(cursor: VirtualCursor) -> void:
	if _hit:
		cursor.die(&"target_already_hit")
		return
	_hit = true
	hit.emit()
	_light_up()
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null:
		audio.call(&"play_sfx", &"hit_target")
	cursor.die(&"target_hit")


func is_hit() -> bool:
	return _hit


func _light_up() -> void:
	if _inner == null:
		return
	var tween := create_tween()
	tween.tween_property(_inner, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(_inner, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
