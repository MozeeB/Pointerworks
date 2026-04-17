class_name Part
extends Area2D
## Part — base class for all grid-placed parts.
##
## Parts are Area2D so `VirtualCursor` (also Area2D) overlap-detection works
## bidirectionally. Layers: parts live on layer 1, cursors on layer 2; parts
## mask cursors (2) so `area_entered` fires on the Part side.
##
## Subclasses override `apply_to_cursor(cursor)`. The base class handles
## rotation bookkeeping + cell tracking.

const CELL_SIZE := 64


@export var data: PartData

var cell: Vector2i = Vector2i.ZERO


func _ready() -> void:
	add_to_group(&"parts")
	# Listen for VirtualCursor overlap. Each subclass's `apply_to_cursor`
	# decides what to do.
	area_entered.connect(_on_area_entered)
	_apply_rotation_from_data()
	_play_place_pop_in()


## Quick scale pop-in so placed parts feel alive. 0 → 1.1 → 1.0, 0.18 s.
func _play_place_pop_in() -> void:
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.06)
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null and audio.has_method(&"play_sfx"):
		audio.call(&"play_sfx", &"place_part")


## Shrink tween for removed parts. Caller awaits the tween.finished
## signal before queue_free to keep the visual clean.
func play_remove_shrink() -> Tween:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
	return tween


func set_cell(c: Vector2i) -> void:
	cell = c


func _apply_rotation_from_data() -> void:
	if data != null:
		rotation = data.rotation_steps * PI * 0.5


## Return a world-space direction vector rotated by this part's rotation_steps.
## Subclasses use this to map a "natural" direction (e.g. RIGHT) to the rotated world dir.
func direction_rotated(base: Vector2) -> Vector2:
	var steps: int = data.rotation_steps if data != null else 0
	return base.rotated(steps * PI * 0.5)


func _on_area_entered(area: Area2D) -> void:
	if area is VirtualCursor:
		apply_to_cursor(area as VirtualCursor)


## Override in subclasses. Runs when a `VirtualCursor` overlaps this part.
## Default: no-op. Emitters, Walls, Targets, Deflectors etc override.
func apply_to_cursor(_cursor: VirtualCursor) -> void:
	pass


## Called by the real OS mouse pointer entering the part's Area2D (Godot built-in).
## Emitter overrides this to spawn cursors.
func on_real_mouse_enter() -> void:
	pass


func on_real_mouse_exit() -> void:
	pass


func rotate_cw() -> void:
	if data == null:
		return
	data = data.with_rotation(data.rotation_steps + 1)
	_apply_rotation_from_data()
