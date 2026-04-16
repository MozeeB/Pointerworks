extends Control
## Credits — scrolling attribution screen.
##
## Day 3 stub: static panel with MIT notice, tool stack, theme acknowledgement.
## Day 7 polish may animate the scroll.

@onready var _back_button: Button = $VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(SceneSwitcher.to_main_menu)
