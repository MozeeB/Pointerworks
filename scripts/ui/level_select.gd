extends Control
## LevelSelect — stub for Day 1. Day 2 adds buttons for each level
## (l01 … l08) gated by `Progress.is_unlocked(id)`.

@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(SceneSwitcher.to_main_menu)
