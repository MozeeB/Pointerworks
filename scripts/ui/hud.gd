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
@onready var _fail_banner: PanelContainer = $FailBanner if has_node("FailBanner") else null
@onready var _fail_label: Label = $FailBanner/Label if has_node("FailBanner/Label") else null
@onready var _onchain_btn: Button = $WinPanel/VBox/OnChainRow/OnChainButton if has_node("WinPanel/VBox/OnChainRow/OnChainButton") else null
@onready var _onchain_status: Label = $WinPanel/VBox/OnChainRow/OnChainStatus if has_node("WinPanel/VBox/OnChainRow/OnChainStatus") else null


signal submit_on_chain_pressed


func _ready() -> void:
	_back_btn.pressed.connect(func(): back_pressed.emit())
	_run_btn.pressed.connect(_on_run_toggle)
	_next_btn.pressed.connect(func(): next_pressed.emit())
	_retry_btn.pressed.connect(_on_retry)
	_menu_btn.pressed.connect(func(): back_pressed.emit())
	if _onchain_btn != null:
		_onchain_btn.pressed.connect(func():
			submit_on_chain_pressed.emit()
			if _onchain_status != null:
				_onchain_status.text = "submitting…"
			_onchain_btn.disabled = true
		)
	_win_panel.hide()
	_win_panel.modulate = Color(1, 1, 1, 0)
	_set_run_label(false)


func set_onchain_available(available: bool) -> void:
	if _onchain_btn == null:
		return
	_onchain_btn.visible = available
	_onchain_btn.disabled = false
	if _onchain_status != null:
		_onchain_status.text = ""


func set_onchain_status(text: String) -> void:
	if _onchain_status != null:
		_onchain_status.text = text


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


## Rotating per-win copy. Level title (if provided) biases selection so
## the copy reads on-theme for each machine.
const WIN_COPY_DEFAULT: PackedStringArray = [
	"Machine calibrated.",
	"Factory line operational.",
	"Reactor critical — in a good way.",
	"Every bolt holds.",
	"Conveyor hums.",
]
const WIN_COPY_BY_LEVEL: Dictionary = {
	"Conveyor": "Conveyor hums.",
	"Press": "Press seated. Clean shear.",
	"Forge": "Ingots cast. Sparks settle.",
	"Refinery": "Streams routed. Pure output.",
	"Lathe": "Cut true to the thousandth.",
	"Kiln": "Temper held. Glaze even.",
	"Foundry": "Jump verified. No slag.",
	"Assembly": "Full line — green across the board.",
	"Reactor": "Reactor critical — in a good way.",
	"Cyclotron": "Loop closed. Particles on rail.",
}


func show_win(cursors_used: int, par: int) -> void:
	_win_title.text = _pick_win_copy()
	var star: String = "⭐ " if cursors_used <= par else ""
	_win_score.text = "%scursors: %d / par %d" % [star, cursors_used, par]
	_win_panel.show()
	var tween := create_tween()
	tween.tween_property(_win_panel, "modulate:a", 1.0, 0.3)


func _pick_win_copy() -> String:
	var level_name: String = _title.text if _title != null else ""
	if WIN_COPY_BY_LEVEL.has(level_name):
		return WIN_COPY_BY_LEVEL[level_name]
	return WIN_COPY_DEFAULT[randi() % WIN_COPY_DEFAULT.size()]


func _set_run_label(running: bool) -> void:
	_run_btn.text = "Stop" if running else "Run"


func _on_run_toggle() -> void:
	_play_button_press(_run_btn)
	# Read current phase label to decide signal.
	if _phase_label.text == "RUN":
		stop_pressed.emit()
	else:
		run_pressed.emit()


## Button-press juice — quick 1.0 → 0.95 → 1.0 squish, 0.1 s total.
func _play_button_press(btn: Control) -> void:
	if btn == null:
		return
	btn.pivot_offset = btn.size * 0.5
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.05)


func _on_retry() -> void:
	_win_panel.modulate = Color(1, 1, 1, 0)
	_win_panel.hide()
	retry_pressed.emit()


## Fail banner — fades in, auto-hidden by Level after 2 s.
func show_fail(missed: int) -> void:
	if _fail_banner == null:
		return
	if _fail_label != null:
		_fail_label.text = "Machine stalled — %d target%s unfed." % [missed, "" if missed == 1 else "s"]
	_fail_banner.show()
	_fail_banner.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(_fail_banner, "modulate:a", 1.0, 0.25)


func hide_fail() -> void:
	if _fail_banner == null:
		return
	var tween := create_tween()
	tween.tween_property(_fail_banner, "modulate:a", 0.0, 0.2)
	tween.tween_callback(_fail_banner.hide)
