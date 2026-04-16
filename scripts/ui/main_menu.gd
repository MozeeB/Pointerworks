extends Control
## MainMenu — entry point. Holds Play / Settings / Credits buttons.
##
## Stub for Day 1. Day 3 adds full Figma-designed layout. Day 4 adds
## Settings button wiring. Day 5 adds optional "Connect Wallet".

@onready var _play_button: Button = $CenterContainer/VBoxContainer/PlayButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	# Prime music on first user gesture (browser autoplay policy).
	var audio_bus := get_node_or_null("/root/AudioBus")
	if audio_bus and audio_bus.has_method("prime_music"):
		audio_bus.prime_music()
	SceneSwitcher.to_level_select()
