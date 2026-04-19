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
@onready var _win_dim: ColorRect = $WinDimOverlay if has_node("WinDimOverlay") else null
@onready var _win_title: Label = $WinPanel/VBox/Title
@onready var _win_score: Label = $WinPanel/VBox/Score
@onready var _next_btn: Button = $WinPanel/VBox/ButtonRow/NextButton
@onready var _retry_btn: Button = $WinPanel/VBox/ButtonRow/RetryButton
@onready var _menu_btn: Button = $WinPanel/VBox/ButtonRow/MenuButton
@onready var _fail_banner: PanelContainer = $FailBanner if has_node("FailBanner") else null
@onready var _fail_label: Label = $FailBanner/Label if has_node("FailBanner/Label") else null
@onready var _onchain_btn: Button = $WinPanel/VBox/OnChainRow/OnChainButton if has_node("WinPanel/VBox/OnChainRow/OnChainButton") else null
@onready var _onchain_status: Label = $WinPanel/VBox/OnChainRow/OnChainStatus if has_node("WinPanel/VBox/OnChainRow/OnChainStatus") else null
@onready var _targets_label: Label = $TopBar/StatsRow/TargetsLabel if has_node("TopBar/StatsRow/TargetsLabel") else null
@onready var _cursors_label: Label = $TopBar/StatsRow/CursorsLabel if has_node("TopBar/StatsRow/CursorsLabel") else null
@onready var _palette: Control = $PartPalette if has_node("PartPalette") else null
@onready var _palette_hint_row: Label = $PaletteHintRow if has_node("PaletteHintRow") else null
@onready var _hint_banner: PanelContainer = $HintBanner if has_node("HintBanner") else null
@onready var _hint_label: Label = $HintBanner/Label if has_node("HintBanner/Label") else null


func get_palette() -> Control:
	return _palette


func _process(_delta: float) -> void:
	# Cheap polling — HUD only exists during a level scene; counts are
	# read directly from the scene-tree groups without signal plumbing.
	if _targets_label != null:
		var targets := get_tree().get_nodes_in_group(&"targets")
		var hit := 0
		for n in targets:
			if n.has_method(&"is_hit") and n.call(&"is_hit"):
				hit += 1
		_targets_label.text = "🎯 %d / %d" % [hit, targets.size()]
	if _cursors_label != null:
		var live := get_tree().get_nodes_in_group(&"virtual_cursors").size()
		_cursors_label.text = "↗ %d" % live


func get_palette_hint_row() -> Label:
	return _palette_hint_row


func show_hint(text: String, duration: float = 4.0) -> void:
	if _hint_banner == null or text == "":
		return
	if _hint_label != null:
		_hint_label.text = text
	_hint_banner.show()
	_hint_banner.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(_hint_banner, "modulate:a", 1.0, 0.4)
	tween.tween_interval(duration)
	tween.tween_property(_hint_banner, "modulate:a", 0.0, 0.6)
	tween.tween_callback(_hint_banner.hide)


signal submit_on_chain_pressed


func _ready() -> void:
	var p := get_node_or_null(^"/root/Progress")
	if p != null and p.has_signal(&"save_reset"):
		p.save_reset.connect(func(reason: String):
			show_hint("Save reset — %s" % reason, 3.0)
		)
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


var _level_id: String = ""
var _prev_best_hint: int = -1


func set_level_title(title: String) -> void:
	if is_instance_valid(_title):
		_title.text = title


func set_level_id(id: String) -> void:
	_level_id = id


func set_prev_best_hint(prev_best: int) -> void:
	# Level passes the best cursors_used BEFORE mark_completed overwrites it.
	# Drives the "🏆 new best!" stamp in show_win.
	_prev_best_hint = prev_best


func _current_level_id_hint() -> String:
	return _level_id


func set_phase(phase: int) -> void:
	match phase:
		PhaseController.Phase.BUILD:
			_phase_label.text = "BUILD"
			_set_run_label(false)
			_win_panel.hide()
			_hide_win_dim_immediate()
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
	# Tiered rating gives players a reason to replay:
	#   ⭐⭐⭐  = at or below par (perfect engineer)
	#   ⭐⭐   = within 1 cursor of par
	#   ⭐    = beat the level at all
	var stars: String
	if cursors_used <= par:
		stars = "⭐⭐⭐"
	elif cursors_used <= par + 1:
		stars = "⭐⭐"
	else:
		stars = "⭐"
	# Also show personal best + "new best!" stamp when applicable.
	# Level sets _prev_best_hint BEFORE mark_completed so we see the real prev.
	var best_text: String = ""
	var prev_best: int = _prev_best_hint
	if prev_best < 0 or cursors_used < prev_best:
		best_text = "  🏆 new best!"
	elif prev_best > 0:
		best_text = "  (best %d)" % prev_best
	_win_score.text = "%s  cursors: %d / par %d%s" % [stars, cursors_used, par, best_text]
	if _win_dim != null:
		_win_dim.show()
		_win_dim.modulate = Color(1, 1, 1, 0)
		var dim_tween := create_tween()
		dim_tween.tween_property(_win_dim, "modulate:a", 1.0, 0.2)
	_win_panel.show()
	var tween := create_tween()
	tween.tween_property(_win_panel, "modulate:a", 1.0, 0.3)


func _hide_win_dim_immediate() -> void:
	if _win_dim != null:
		_win_dim.hide()


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
	_hide_win_dim_immediate()
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
