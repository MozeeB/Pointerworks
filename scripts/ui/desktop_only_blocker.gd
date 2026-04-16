extends CanvasLayer
## DesktopOnlyBlocker — terminal screen if the game is loaded on mobile.
##
## Checked from MainMenu._ready. Covers the screen with a fullscreen
## panel and blocks further input.


static func is_mobile_device() -> bool:
	if OS.has_feature("mobile"):
		return true
	if OS.has_feature("android") or OS.has_feature("ios"):
		return true
	return DisplayServer.is_touchscreen_available()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
