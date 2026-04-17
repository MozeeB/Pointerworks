extends Control
## PartPalette — bottom-row Control shown during BUILD when the active
## level exposes `palette_types`. Click-to-select workflow (not drag):
##
##   1. Click a palette button → that PartData.Type becomes active.
##   2. Click an empty grid cell (Level handles the routing) → part spawns.
##   3. Right-click a placed, non-locked part → it's removed (see Level).
##   4. `R` or `pw_rotate` rotates the active selection; if hovered part,
##      Level rotates that instead (see Level._unhandled_input).
##
## Each slot tracks remaining count; -1 = unlimited.

signal slot_selected(type_index: int)

const ROW_HEIGHT := 64
const SLOT_WIDTH := 72

# Type id → display label + palette color hint for the icon.
const SLOT_META: Dictionary = {
	0: ["Emitter", Color(0.9117, 0.6466, 0.2275, 1)],
	1: ["Wall",    Color(0.2902, 0.3137, 0.3764, 1)],
	2: ["Target",  Color(0.2274, 0.8313, 0.8392, 1)],
	3: ["Deflect", Color(0.9489, 0.9411, 0.9137, 1)],
	4: ["Split",   Color(0.8509, 0.2745, 0.7019, 1)],
	5: ["Speed",   Color(0.9117, 0.6466, 0.2275, 1)],
	6: ["Portal",  Color(0.8509, 0.2745, 0.7019, 1)],
}

var _types: Array[int] = []
var _counts: Dictionary = {}  # type_index (int) → remaining (int); -1 = ∞
var _selected: int = -1
var _buttons: Dictionary = {}  # type_index → Button


func configure(types: Array, counts: Array) -> void:
	_clear()
	_types.clear()
	for t in types:
		_types.append(int(t))
	_counts.clear()
	for i in _types.size():
		var c: int = counts[i] if i < counts.size() else -1
		_counts[_types[i]] = int(c)
	_build_ui()
	visible = _types.size() > 0


func consume(type_index: int) -> bool:
	# Returns true if the caller may proceed with the placement.
	if not _counts.has(type_index):
		return false
	var remaining: int = _counts[type_index]
	if remaining == 0:
		return false
	if remaining > 0:
		_counts[type_index] = remaining - 1
		_refresh_slot(type_index)
	if _counts[type_index] == 0:
		_select_next_available()
	return true


func restore(type_index: int) -> void:
	# Called when a placed part is removed.
	if not _counts.has(type_index):
		return
	var remaining: int = _counts[type_index]
	if remaining == -1:
		return
	_counts[type_index] = remaining + 1
	_refresh_slot(type_index)


func selected() -> int:
	return _selected


func _clear() -> void:
	for c in get_children():
		c.queue_free()
	_buttons.clear()
	_selected = -1


func _build_ui() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	add_child(row)
	for t in _types:
		var meta: Array = SLOT_META.get(t, ["?", Color.WHITE])
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(SLOT_WIDTH, ROW_HEIGHT)
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = _slot_label(int(t), meta[0])
		btn.add_theme_color_override(&"font_color", meta[1])
		btn.pressed.connect(_on_slot_pressed.bind(int(t)))
		row.add_child(btn)
		_buttons[int(t)] = btn
	_select_next_available()


func _slot_label(type_index: int, name: String) -> String:
	var c: int = _counts.get(type_index, 0)
	var badge := "∞" if c < 0 else str(c)
	return "%s\n%s" % [name, badge]


func _refresh_slot(type_index: int) -> void:
	var btn: Button = _buttons.get(type_index, null)
	if btn == null:
		return
	var meta: Array = SLOT_META.get(type_index, ["?", Color.WHITE])
	btn.text = _slot_label(type_index, meta[0])
	if _counts[type_index] == 0:
		btn.disabled = true
		btn.button_pressed = false


func _select_slot(type_index: int) -> void:
	_selected = type_index
	for t in _buttons:
		var btn: Button = _buttons[t]
		btn.button_pressed = (t == type_index)
	slot_selected.emit(type_index)


func _select_next_available() -> void:
	for t in _types:
		if _counts.get(int(t), 0) != 0:
			_select_slot(int(t))
			return
	_selected = -1


func select_slot_by_index(slot_index: int) -> void:
	# 0-based index into _types; used by number-key shortcuts.
	if slot_index < 0 or slot_index >= _types.size():
		return
	var t: int = _types[slot_index]
	if _counts.get(t, 0) == 0:
		return
	_select_slot(t)


func _on_slot_pressed(type_index: int) -> void:
	if _counts.get(type_index, 0) == 0:
		return
	_select_slot(type_index)
