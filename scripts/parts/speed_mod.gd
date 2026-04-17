class_name SpeedMod
extends Part
## SpeedMod — scales cursor velocity on pass-through.
##
## Two variants: fast (`factor = 2.0`) or slow (`factor = 0.5`). The node's
## `factor` export (or `PartData.variant` at load time) decides which.
## Cursor passes through; no rotation change. To prevent the same cursor
## re-scaling repeatedly while still overlapping, we tag the cursor via a
## meta key and only apply once per entry.

const MAX_SPEED := 1024.0
const MIN_SPEED := 32.0
const META_KEY := &"speed_mod_touched"

@export_range(0.1, 8.0, 0.1) var factor: float = 2.0


func _ready() -> void:
	super()
	_apply_palette()
	var s := get_node_or_null(^"/root/Settings")
	if s != null:
		s.settings_changed.connect(_apply_palette)


func _apply_palette() -> void:
	if has_node("Body"):
		var body: Polygon2D = $Body
		body.color = AppPalette.get_color(AppPalette.Swatch.EMITTER_AMBER)


func apply_to_cursor(cursor: VirtualCursor) -> void:
	# PartData.variant overrides @export factor when present:
	#   0 = slow ×0.5, 1 = fast ×2.0.
	var f: float = factor
	if data != null:
		f = 0.5 if data.variant == 0 else 2.0

	# Avoid double-apply on the same overlap.
	var tag := get_instance_id()
	if cursor.has_meta(META_KEY) and int(cursor.get_meta(META_KEY)) == tag:
		return
	cursor.set_meta(META_KEY, tag)

	var scaled: Vector2 = cursor.velocity * f
	var len: float = clampf(scaled.length(), MIN_SPEED, MAX_SPEED)
	cursor.velocity = scaled.normalized() * len
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null:
		audio.call(&"play_sfx", &"deflect")
