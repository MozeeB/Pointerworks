extends CanvasLayer
## PauseMenu — Esc toggles. Lives inside HUD canvas. Pauses tree while open.

signal resume_pressed
signal restart_pressed
signal settings_pressed
signal back_pressed

@onready var _overlay: ColorRect = $Overlay
@onready var _panel: PanelContainer = $Panel
@onready var _resume: Button = $Panel/VBox/ResumeButton
@onready var _restart: Button = $Panel/VBox/RestartButton
@onready var _settings: Button = $Panel/VBox/SettingsButton
@onready var _back: Button = $Panel/VBox/BackButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_menu()
	_resume.pressed.connect(_on_resume)
	_restart.pressed.connect(func(): restart_pressed.emit())
	_settings.pressed.connect(func(): settings_pressed.emit())
	_back.pressed.connect(func(): back_pressed.emit())


func show_menu() -> void:
	visible = true
	get_tree().paused = true


func hide_menu() -> void:
	visible = false
	get_tree().paused = false


func toggle() -> void:
	if visible:
		_on_resume()
	else:
		show_menu()


func _on_resume() -> void:
	hide_menu()
	resume_pressed.emit()
