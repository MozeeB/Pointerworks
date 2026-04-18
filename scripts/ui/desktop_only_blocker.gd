extends CanvasLayer
## ViewportBlocker — terminal screen for too-small / portrait viewports.
##
## Mobile is now SUPPORTED (touch = tap-to-place, long-press = remove).
## We only block when the viewport is genuinely too small to fit the
## 16×10 grid + HUD, OR when the device is held in portrait. Players
## are nudged to rotate to landscape rather than turned away.
##
## Listens for live `size_changed` so a mid-session window resize or a
## device rotation toggles the blocker without reload.

const MIN_WIDTH: int = 720
const MIN_HEIGHT: int = 480


static func is_viewport_too_small() -> bool:
	var size := DisplayServer.window_get_size()
	return size.x < MIN_WIDTH or size.y < MIN_HEIGHT


static func is_portrait() -> bool:
	var size := DisplayServer.window_get_size()
	return size.y > size.x


static func should_block() -> bool:
	return is_viewport_too_small() or is_portrait()


# Kept for back-compat with main_menu callsite; aliased to should_block.
static func is_mobile_device() -> bool:
	return false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.size_changed.connect(_on_viewport_resized)
	_refresh_visibility()


func _on_viewport_resized() -> void:
	# Defer one frame so window-size queries return the new dims.
	call_deferred(&"_refresh_visibility")
	call_deferred(&"_refresh_copy")


func _refresh_visibility() -> void:
	visible = should_block()


func _refresh_copy() -> void:
	# Adjust title/body so the user knows whether to rotate or resize.
	var title := get_node_or_null(^"VBox/Title") as Label
	var body1 := get_node_or_null(^"VBox/Body1") as Label
	var body2 := get_node_or_null(^"VBox/Body2") as Label
	if title == null or body1 == null or body2 == null:
		return
	if is_portrait():
		title.text = "Rotate to landscape"
		body1.text = "Pointerworks runs in landscape orientation."
		body2.text = "Turn your device sideways to play."
	else:
		title.text = "Window too small"
		body1.text = "Pointerworks needs at least %d × %d." % [MIN_WIDTH, MIN_HEIGHT]
		body2.text = "Resize the window or open in fullscreen."
