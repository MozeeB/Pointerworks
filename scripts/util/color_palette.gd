class_name AppPalette
extends RefCounted
## AppPalette — 6-color palette for all in-game art.
##
## Renamed from `AppPalette` because Godot 4 has a built-in
## `AppPalette` resource type (used by ColorPicker presets) that wins
## name resolution and hides this class's members. `AppPalette` is unique
## to this project.
##
## No hex literals should appear in game code — always route through
## `AppPalette.get_color(swatch)` so the colorblind variant can swap
## amber → blue at runtime (Settings.colorblind_palette).
##
## NOTE: `Swatch` (not `Name`) — `Name` collides with a GDScript reserved
## identifier used in node scope lookup and fails to parse.

const BG_DARK := Color("#0E1320")
const FG_LIGHT := Color("#F2F0E9")
const EMITTER_AMBER := Color("#E8A53A")
const CURSOR_MAGENTA := Color("#D946B3")
const TARGET_CYAN := Color("#3AD4D6")
const WALL_GREY := Color("#4A5060")

# Colorblind-friendly substitute for amber.
const EMITTER_AMBER_CB := Color("#2E7AE8")


enum Swatch {
	BG_DARK,
	FG_LIGHT,
	EMITTER_AMBER,
	CURSOR_MAGENTA,
	TARGET_CYAN,
	WALL_GREY,
}


static func get_color(swatch: Swatch) -> Color:
	var colorblind: bool = _is_colorblind_enabled()
	match swatch:
		Swatch.BG_DARK:
			return BG_DARK
		Swatch.FG_LIGHT:
			return FG_LIGHT
		Swatch.EMITTER_AMBER:
			return EMITTER_AMBER_CB if colorblind else EMITTER_AMBER
		Swatch.CURSOR_MAGENTA:
			return CURSOR_MAGENTA
		Swatch.TARGET_CYAN:
			return TARGET_CYAN
		Swatch.WALL_GREY:
			return WALL_GREY
	return FG_LIGHT


static func _is_colorblind_enabled() -> bool:
	# Settings autoload may not yet be registered in early test scenes —
	# fall back to false if absent.
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var settings := tree.root.get_node_or_null("Settings")
	if settings == null:
		return false
	return settings.colorblind_palette
