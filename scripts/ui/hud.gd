extends CanvasLayer
## HUD — minimal Day 2 in-level overlay.
##
## Elements:
##   TopBar — level title, phase label, Back button
##   RunBar — Run / Stop toggle button
##   WinPanel — hidden by default; fades in on level complete with
##              par-cursors ⭐ rating, Next + Retry buttons.
## PartPalette + FailBanner land later (Day 2 PM + Day 4).

signal run_pressed
signal stop_pressed
signal back_pressed
signal next_pressed
signal retry_pressed

@onready var _title: Label = $TopBar/TitleLabel
@onready var _phase_label: Label = $TopBar/PhaseLabel
@onready var _back_btn: Button = $TopBar/BackButton
@onready var _run_btn: Button = $RunBar/RunButton
@onready var _win_panel: PanelContainer = $WinPanel
@onready var _win_title: Label = $WinPanel/VBox/Title
@onready var _win_score: Label = $WinPanel/VBox/Score
@onready var _next_btn: Button = $WinPanel/VBox/ButtonRow/NextButton
@onready var _retry_btn: Button = $WinPanel/VBox/ButtonRow/RetryButton
@onready var _menu_btn: Button = $WinPanel/VBox/ButtonRow/MenuButton


func _ready() -> void:
	_back_btn.pressed.connect(func(): back_pressed.emit())
	_run_btn.pressed.connect(_on_run_toggle)
	_next_btn.pressed.connect(func(): next_pressed.emit())
	_retry_btn.pressed.connect(_on_retry)
	_menu_btn.pressed.connect(func(): back_pressed.emit())
	_win_panel.hide()
	_win_panel.modulate = Color(1, 1, 1, 0)
	_set_run_label(false)


func set_level_title(title: String) -> void:
	if is_instance_valid(_title):
		_title.text = title


func set_phase(phase: int) -> void:
	match phase:
		PhaseController.Phase.BUILD:
			_phase_label.text = "BUILD"
			_set_run_label(false)
			_win_panel.hide()
		PhaseController.Phase.RUN:
			_phase_label.text = "RUN"
			_set_run_label(true)
		PhaseController.Phase.WIN:
			_phase_label.text = "WIN"
		PhaseController.Phase.FAIL:
			_phase_label.text = "FAIL"
			_set_run_label(false)


func show_win(cursors_used: int, par: int) -> void:
	_win_title.text = "Machine calibrated."
	var star: String = "⭐ " if cursors_used <= par else ""
	_win_score.text = "%scursors: %d / par %d" % [star, cursors_used, par]
	_win_panel.show()
	var tween := create_tween()
	tween.tween_property(_win_panel, "modulate:a", 1.0, 0.3)


func _set_run_label(running: bool) -> void:
	_run_btn.text = "Stop" if running else "Run"


func _on_run_toggle() -> void:
	# Read current phase label to decide signal.
	if _phase_label.text == "RUN":
		stop_pressed.emit()
	else:
		run_pressed.emit()


func _on_retry() -> void:
	_win_panel.modulate = Color(1, 1, 1, 0)
	_win_panel.hide()
	retry_pressed.emit()
