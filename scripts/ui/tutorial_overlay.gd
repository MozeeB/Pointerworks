extends CanvasLayer
## TutorialOverlay — first-run onboarding panel.
##
## Shows once per `Progress.seen_tutorial`. Two steps: mechanic overview +
## controls. Dismiss sets the flag. Process always; blocks input.

signal dismissed

@onready var _panel: PanelContainer = $Panel
@onready var _ok_btn: Button = $Panel/VBox/OkButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ok_btn.pressed.connect(_on_dismiss)


func _on_dismiss() -> void:
	var progress := get_node_or_null(^"/root/Progress")
	if progress != null and progress.has_method(&"set_tutorial_seen"):
		progress.call(&"set_tutorial_seen")
	queue_free()
	dismissed.emit()
