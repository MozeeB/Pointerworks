extends CanvasLayer
## SettingsDialog — volume sliders + colorblind + fullscreen toggles.
##
## Binds to Settings autoload. Changes persist via Settings.save() on
## slider release + on CheckButton toggle.

signal closed

@onready var _overlay: ColorRect = $Overlay
@onready var _panel: PanelContainer = $Panel
@onready var _master: HSlider = $Panel/VBox/MasterRow/Slider
@onready var _music: HSlider = $Panel/VBox/MusicRow/Slider
@onready var _sfx: HSlider = $Panel/VBox/SFXRow/Slider
@onready var _fullscreen: CheckButton = $Panel/VBox/FullscreenCheck
@onready var _colorblind: CheckButton = $Panel/VBox/ColorblindCheck
@onready var _close: Button = $Panel/VBox/CloseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var s := get_node_or_null(^"/root/Settings")
	if s != null:
		_master.value = s.master_vol if "master_vol" in s else 1.0
		_music.value = s.music_vol if "music_vol" in s else 1.0
		_sfx.value = s.sfx_vol if "sfx_vol" in s else 1.0
		_fullscreen.button_pressed = s.fullscreen if "fullscreen" in s else false
		_colorblind.button_pressed = s.colorblind_palette if "colorblind_palette" in s else false
	_master.value_changed.connect(func(v): _apply("master_vol", v))
	_music.value_changed.connect(func(v): _apply("music_vol", v))
	_sfx.value_changed.connect(func(v): _apply("sfx_vol", v))
	_fullscreen.toggled.connect(func(p): _apply("fullscreen", p))
	_colorblind.toggled.connect(func(p): _apply("colorblind_palette", p))
	_close.pressed.connect(_on_close)


func open() -> void:
	visible = true


func _on_close() -> void:
	visible = false
	closed.emit()


func _apply(key: String, value) -> void:
	var s := get_node_or_null(^"/root/Settings")
	if s == null:
		return
	# Route through typed setters so side-effects fire (volume apply,
	# fullscreen switch, colorblind signal).
	match key:
		"master_vol": s.call(&"set_master_vol", float(value))
		"music_vol": s.call(&"set_music_vol", float(value))
		"sfx_vol": s.call(&"set_sfx_vol", float(value))
		"fullscreen": s.call(&"set_fullscreen", bool(value))
		"colorblind_palette": s.call(&"set_colorblind", bool(value))
