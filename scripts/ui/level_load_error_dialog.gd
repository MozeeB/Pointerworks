extends CanvasLayer
## LevelLoadErrorDialog — shown when a `.gd` builder / `.tres` fails to
## validate or the scene layout is malformed. One button: back to menu.

signal back_pressed

@onready var _label: Label = $Panel/VBox/MessageLabel
@onready var _btn: Button = $Panel/VBox/BackButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_btn.pressed.connect(func(): back_pressed.emit())


func set_message(text: String) -> void:
	if _label != null:
		_label.text = text
