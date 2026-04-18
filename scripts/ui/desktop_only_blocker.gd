extends CanvasLayer
## DesktopOnlyBlocker — terminal screen for too-small viewports + mobile.
##
## Checked from MainMenu._ready and listens for live `size_changed` so a
## mid-session window resize toggles the blocker without reload.

const MIN_WIDTH: int = 1100
const MIN_HEIGHT: int = 620


static func is_mobile_device() -> bool:
	if OS.has_feature("mobile"):
		return true
	if OS.has_feature("android") or OS.has_feature("ios"):
		return true
	return DisplayServer.is_touchscreen_available()


static func is_viewport_too_small() -> bool:
	var size := DisplayServer.window_get_size()
	return size.x < MIN_WIDTH or size.y < MIN_HEIGHT


static func should_block() -> bool:
	return is_mobile_device() or is_viewport_too_small()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.size_changed.connect(_on_viewport_resized)
	_refresh_visibility()


func _on_viewport_resized() -> void:
	# Defer one frame so window-size queries return the new dims.
	call_deferred(&"_refresh_visibility")


func _refresh_visibility() -> void:
	visible = should_block()
