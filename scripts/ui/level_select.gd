extends Control
## LevelSelect — grid of level buttons.
##
## Day 2: lists l01..l04 (unlocked via Progress). Day 3 grows to l01..l08;
## Day 6 adds l09, l10. A locked level shows a padlock and disables click.

const LEVEL_COUNT: int = 10
const FIRST_AVAILABLE: int = 10  # Day 6: all 10 levels shipped.

@onready var _back_button: Button = $VBox/BackButton
@onready var _grid: GridContainer = $VBox/Grid if has_node("VBox/Grid") else null


func _ready() -> void:
	_back_button.pressed.connect(SceneSwitcher.to_main_menu)
	if _grid != null:
		_populate_grid()


func _populate_grid() -> void:
	for i in range(1, LEVEL_COUNT + 1):
		var id := "l%02d" % i
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(128, 96)
		btn.text = _button_label(id, i)
		# All 10 levels unlocked from launch — players can free-pick. Progress
		# still tracks completion (⭐ on win), but sequential gating felt
		# punishing in playtests. Re-enable sequential gating by ANDing
		# `_is_unlocked(id)` here if the ladder feel is wanted post-jam.
		var unlocked := i <= FIRST_AVAILABLE
		btn.disabled = not unlocked
		if unlocked:
			# `.bind(id)` snapshots the id String into the Callable args at
			# this iteration. Without it, the lambda would close over the
			# loop-scoped `id` variable by reference, and every button would
			# load whatever id holds at click-time (typically the last
			# iteration's value). This was the L1-loads-wrong-level bug.
			btn.pressed.connect(_on_level_pressed.bind(id))
		_grid.add_child(btn)


func _on_level_pressed(level_id: String) -> void:
	SceneSwitcher.to_level(level_id)


func _button_label(id: String, n: int) -> String:
	# Label grid button with lvl# + ⭐ rating + best-cursor count so the
	# player sees at a glance where there's still room to improve. The
	# 3-star tiered rating matches the WinDialog and gives replay value.
	var progress := get_node_or_null(^"/root/Progress")
	var stars := ""
	var best_line := ""
	if progress != null and progress.has_method(&"is_completed") and progress.call(&"is_completed", id):
		var par := _par_for(id)
		var best: int = int(progress.call(&"cursors_used_for", id)) if progress.has_method(&"cursors_used_for") else -1
		if best > 0 and par > 0:
			if best <= par:
				stars = " ⭐⭐⭐"
			elif best <= par + 1:
				stars = " ⭐⭐"
			else:
				stars = " ⭐"
			best_line = "\nbest %d / par %d" % [best, par]
		else:
			stars = " ⭐"
	var lock := ""
	if n > FIRST_AVAILABLE:
		lock = " 🔒"
	return "%d%s%s%s" % [n, stars, lock, best_line]


func _par_for(id: String) -> int:
	# Load the level GDScript and read its PAR_CURSORS constant. Cheap —
	# GDScripts are small + cached after first load.
	var path := "res://data/levels/%s.gd" % id
	if not ResourceLoader.exists(path):
		return -1
	var scr: GDScript = load(path)
	if scr == null:
		return -1
	var consts: Dictionary = scr.get_script_constant_map()
	return int(consts.get("PAR_CURSORS", -1))


func _is_unlocked(id: String) -> bool:
	var progress := get_node_or_null(^"/root/Progress")
	if progress == null:
		return id == "l01"
	if progress.has_method(&"is_unlocked"):
		return bool(progress.call(&"is_unlocked", id))
	return id == "l01"
