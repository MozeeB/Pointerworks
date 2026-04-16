class_name ColorPalette
extends RefCounted
## ColorPalette — 6-color palette for all in-game art.
##
## No hex literals should appear in game code — always route through
## `ColorPalette.get_color(name)` so the colorblind variant can swap
## amber → blue at runtime (Settings.colorblind_palette).

const BG_DARK := Color("#0E1320")
const FG_LIGHT := Color("#F2F0E9")
const EMITTER_AMBER := Color("#E8A53A")
const CURSOR_MAGENTA := Color("#D946B3")
const TARGET_CYAN := Color("#3AD4D6")
const WALL_GREY := Color("#4A5060")

# Colorblind-friendly substitute for amber.
const EMITTER_AMBER_CB := Color("#2E7AE8")


enum Name {
	BG_DARK,
	FG_LIGHT,
	EMITTER_AMBER,
	CURSOR_MAGENTA,
	TARGET_CYAN,
	WALL_GREY,
}


static func get_color(name: Name) -> Color:
	var colorblind: bool = _is_colorblind_enabled()
	match name:
		Name.BG_DARK:
			return BG_DARK
		Name.FG_LIGHT:
			return FG_LIGHT
		Name.EMITTER_AMBER:
			return EMITTER_AMBER_CB if colorblind else EMITTER_AMBER
		Name.CURSOR_MAGENTA:
			return CURSOR_MAGENTA
		Name.TARGET_CYAN:
			return TARGET_CYAN
		Name.WALL_GREY:
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
