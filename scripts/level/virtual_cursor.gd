class_name VirtualCursor
extends Area2D
## VirtualCursor — the "working fluid" of every machine.
##
## Emitted by an Emitter when the real OS cursor hovers it. Flies at a fixed
## velocity, mutated by Deflector / Splitter / Speed Modifier / Teleporter.
## Dies on: Wall hit, grid-edge exit, TTL expiry, or Target-hit.
##
## Lifecycle invariants (enforce in tests):
##   - `_alive` flips false exactly once; `died` signal fires exactly once.
##   - After `die()`, `_physics_process` becomes a no-op; node queue_free'd on tween end.
##   - Trail renders in world space via `top_level = true` on the Line2D child.

signal died(cause: StringName)

const DEFAULT_SPEED := 256.0  # px/sec
const DEFAULT_TTL := 5.0
const TRAIL_MAX_POINTS := 60

@export var velocity: Vector2 = Vector2(DEFAULT_SPEED, 0)
@export var ttl: float = DEFAULT_TTL
## World-space rect the cursor must stay inside. Assign from GridSystem at spawn.
@export var grid_rect: Rect2 = Rect2(0, 0, 1280, 720)

var _alive: bool = true

@onready var _trail: Line2D = $Trail
@onready var _glow_trail: Line2D = $GlowTrail if has_node("GlowTrail") else null


func _ready() -> void:
	add_to_group(&"virtual_cursors")
	_trail.top_level = true
	if _glow_trail != null:
		_glow_trail.top_level = true
	# Orient the arrow polygon to face the velocity direction.
	if velocity.length_squared() > 0.0:
		rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	if not _alive:
		return
	global_position += velocity * delta
	# Keep arrow facing direction of travel after each Deflector turn.
	if velocity.length_squared() > 0.0:
		rotation = velocity.angle()
	ttl -= delta
	_append_trail_point(global_position)
	if ttl <= 0.0:
		die(&"ttl")
	elif not grid_rect.has_point(global_position):
		die(&"off_grid")


func _append_trail_point(world_pt: Vector2) -> void:
	_trail.add_point(world_pt)
	if _trail.get_point_count() > TRAIL_MAX_POINTS:
		_trail.remove_point(0)
	if _glow_trail != null:
		_glow_trail.add_point(world_pt)
		if _glow_trail.get_point_count() > TRAIL_MAX_POINTS:
			_glow_trail.remove_point(0)


func die(cause: StringName) -> void:
	if not _alive:
		return
	_alive = false
	died.emit(cause)
	# Different visual per death cause. Keep it short — jam polish.
	var tween := create_tween()
	match cause:
		&"wall":
			modulate = Color(1.0, 0.3, 0.3, 1.0)
			tween.tween_property(self, "modulate:a", 0.0, 0.2)
		&"off_grid":
			tween.tween_property(self, "modulate:a", 0.0, 0.15)
		&"ttl":
			tween.tween_property(self, "modulate:a", 0.0, 0.3)
		_:
			tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)


func is_alive() -> bool:
	return _alive
