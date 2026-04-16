extends Control
## MainMenu — entry point. Holds Play / Settings / Credits buttons.
##
## Stub for Day 1. Day 3 adds full Figma-designed layout. Day 4 adds
## Settings button wiring. Day 5 adds optional "Connect Wallet".

@onready var _play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var _credits_button: Button = $CenterContainer/VBoxContainer/CreditsButton
@onready var _title_label: Label = $CenterContainer/VBoxContainer/TitleLabel


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	if _credits_button != null:
		_credits_button.pressed.connect(_on_credits_pressed)
	_start_title_idle()


func _on_play_pressed() -> void:
	# Prime music on first user gesture (browser autoplay policy).
	var audio_bus := get_node_or_null("/root/AudioBus")
	if audio_bus and audio_bus.has_method("prime_music"):
		audio_bus.prime_music()
	SceneSwitcher.to_level_select()


func _on_credits_pressed() -> void:
	SceneSwitcher.to_credits()


## Subtle title idle — ±3 px vertical float, 2 s loop.
func _start_title_idle() -> void:
	if _title_label == null:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(_title_label, "position:y", _title_label.position.y + 3.0, 1.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_title_label, "position:y", _title_label.position.y - 3.0, 1.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_title_label, "position:y", _title_label.position.y, 1.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
