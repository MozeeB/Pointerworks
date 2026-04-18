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
@onready var _ring: Polygon2D = $Ring if has_node("Ring") else null
@onready var _core: Polygon2D = $Core if has_node("Core") else null

# Cached pulse material so reset() can restore it.
var _pulse_material: Material = null


func _ready() -> void:
	super()
	add_to_group(&"targets")
	if _core != null:
		_pulse_material = _core.material


func apply_to_cursor(_cursor: VirtualCursor) -> void:
	# Cursor passes through — targets do NOT consume the cursor, so one
	# cursor can light multiple targets in sequence (Theme: Forge level).
	# Subsequent cursors overlapping an already-hit target are no-ops.
	if _hit:
		return
	_hit = true
	hit.emit()
	_disable_pulse()
	_light_up()
	_celebrate_burst()
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null:
		audio.call(&"play_sfx", &"hit_target")


## C2 — 8 small triangles fly outward + fade. WIN_GREEN tint.
## Pure Polygon2D (no GPUParticles2D) for GL Compatibility safety.
func _celebrate_burst() -> void:
	var burst_color := AppPalette.get_color(AppPalette.Swatch.WIN_GREEN)
	for i in 8:
		var ang := (float(i) / 8.0) * TAU
		var dir := Vector2.RIGHT.rotated(ang)
		var shard := Polygon2D.new()
		shard.polygon = PackedVector2Array([
			Vector2(0, -3), Vector2(6, 0), Vector2(0, 3),
		])
		shard.color = burst_color
		shard.rotation = ang
		add_child(shard)
		shard.position = Vector2.ZERO
		var tween := create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(shard, "position", dir * 28.0, 0.5)
		tween.tween_property(shard, "modulate:a", 0.0, 0.5)
		tween.chain().tween_callback(shard.queue_free)


func is_hit() -> bool:
	return _hit


func reset() -> void:
	_hit = false
	if _inner != null:
		_inner.modulate = Color(1.0, 1.0, 1.0, 1.0)
	# Restore pulse so the unhit target re-animates after a Retry.
	if _ring != null:
		_ring.material = _pulse_material
	if _core != null:
		_core.material = _pulse_material


func _disable_pulse() -> void:
	if _ring != null:
		_ring.material = null
	if _core != null:
		_core.material = null


func _light_up() -> void:
	if _inner == null:
		return
	var tween := create_tween()
	tween.tween_property(_inner, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(_inner, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
