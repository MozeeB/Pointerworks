extends Control
## MainMenu — entry point. Holds Play / Settings / Credits buttons.
##
## Stub for Day 1. Day 3 adds full Figma-designed layout. Day 4 adds
## Settings button wiring. Day 5 adds optional "Connect Wallet".

const DESKTOP_BLOCKER_SCENE := preload("res://scenes/ui/desktop_only_blocker.tscn")
const TUTORIAL_SCENE := preload("res://scenes/ui/tutorial_overlay.tscn")

@onready var _play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var _credits_button: Button = $CenterContainer/VBoxContainer/CreditsButton
@onready var _wallet_button: Button = $CenterContainer/VBoxContainer/ConnectWalletButton if has_node("CenterContainer/VBoxContainer/ConnectWalletButton") else null
@onready var _title_label: Label = $CenterContainer/VBoxContainer/TitleLabel


func _ready() -> void:
	if _check_mobile_blocker():
		return
	_play_button.pressed.connect(_on_play_pressed)
	if _credits_button != null:
		_credits_button.pressed.connect(_on_credits_pressed)
	if _wallet_button != null:
		_wire_wallet_button()
	_start_title_idle()
	_maybe_show_tutorial()


func _wire_wallet_button() -> void:
	var w := get_node_or_null(^"/root/Web3Bridge")
	if w == null:
		_wallet_button.hide()
		return
	_wallet_button.pressed.connect(_on_wallet_pressed)
	w.wallet_connected.connect(_on_wallet_connected)
	w.wallet_error.connect(_on_wallet_error)
	_refresh_wallet_label()


func _on_wallet_pressed() -> void:
	var w := get_node_or_null(^"/root/Web3Bridge")
	if w == null:
		return
	if w.call(&"is_wallet_connected"):
		w.call(&"disconnect_wallet")
		_wallet_button.text = "Connect Wallet (optional)"
	else:
		w.call(&"connect_wallet")
		_wallet_button.text = "Connecting…"


func _on_wallet_connected(address: String) -> void:
	if _wallet_button == null:
		return
	var short := address.substr(0, 6) + "…" + address.substr(address.length() - 4)
	_wallet_button.text = short


func _on_wallet_error(msg: String) -> void:
	push_warning("Wallet: %s" % msg)
	if _wallet_button != null and _wallet_button.text == "Connecting…":
		_wallet_button.text = "Connect Wallet (optional)"


func _refresh_wallet_label() -> void:
	var w := get_node_or_null(^"/root/Web3Bridge")
	if w == null or _wallet_button == null:
		return
	if w.call(&"is_wallet_connected"):
		var a: String = str(w.call(&"get_address"))
		_on_wallet_connected(a)


func _check_mobile_blocker() -> bool:
	# Import the class script so the static is reachable.
	var scr := preload("res://scripts/ui/desktop_only_blocker.gd")
	if scr != null and scr.should_block():
		add_child(DESKTOP_BLOCKER_SCENE.instantiate())
		return true
	return false


func _maybe_show_tutorial() -> void:
	var progress := get_node_or_null(^"/root/Progress")
	if progress == null:
		return
	if progress.get(&"seen_tutorial") == true:
		return
	add_child(TUTORIAL_SCENE.instantiate())


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
