extends Control
## LevelSelect — grid of level buttons.
##
## Day 2: lists l01..l04 (unlocked via Progress). Day 3 grows to l01..l08;
## Day 6 adds l09, l10. A locked level shows a padlock and disables click.

const LEVEL_COUNT: int = 10
const FIRST_AVAILABLE: int = 8  # Day 3 end: l01..l08 exist. Day 6 bumps to 10.

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
		var unlocked := _is_unlocked(id) and i <= FIRST_AVAILABLE
		btn.disabled = not unlocked
		if unlocked:
			btn.pressed.connect(func(): SceneSwitcher.to_level(id))
		_grid.add_child(btn)


func _button_label(id: String, n: int) -> String:
	var progress := get_node_or_null(^"/root/Progress")
	var star := ""
	if progress != null and progress.has_method(&"is_completed") and progress.call(&"is_completed", id):
		star = " ⭐"
	var lock := ""
	if n > FIRST_AVAILABLE:
		lock = " 🔒"
	return "%d%s%s" % [n, star, lock]


func _is_unlocked(id: String) -> bool:
	var progress := get_node_or_null(^"/root/Progress")
	if progress == null:
		return id == "l01"
	if progress.has_method(&"is_unlocked"):
		return bool(progress.call(&"is_unlocked", id))
	return id == "l01"
