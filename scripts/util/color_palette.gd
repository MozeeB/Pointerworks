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

# Day 9 UI/UX additions — feedback / hierarchy / state colors.
const FAIL_RED := Color("#F2534C")
const WIN_GREEN := Color("#5BD87C")
const HOVER_TINT := Color("#FFFFFF")            # multiplied at low alpha for cell hover ring
const SELECTION_RING := Color("#E8A53A")        # palette slot selection (amber match)
const OVERLAY_DIM := Color("#000000")           # used at ~55% alpha behind modals
const MUTED_TEXT := Color("#8E9499")            # secondary HUD text
const ACCENT := Color("#F2F0E9")                # cell-flash + generic highlights


enum Swatch {
	BG_DARK,
	FG_LIGHT,
	EMITTER_AMBER,
	CURSOR_MAGENTA,
	TARGET_CYAN,
	WALL_GREY,
	FAIL_RED,
	WIN_GREEN,
	HOVER_TINT,
	SELECTION_RING,
	OVERLAY_DIM,
	MUTED_TEXT,
	ACCENT,
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
		Swatch.FAIL_RED:
			return FAIL_RED
		Swatch.WIN_GREEN:
			return WIN_GREEN
		Swatch.HOVER_TINT:
			return HOVER_TINT
		Swatch.SELECTION_RING:
			# Selection ring matches amber, so swap on colorblind too.
			return EMITTER_AMBER_CB if colorblind else SELECTION_RING
		Swatch.OVERLAY_DIM:
			return OVERLAY_DIM
		Swatch.MUTED_TEXT:
			return MUTED_TEXT
		Swatch.ACCENT:
			return ACCENT
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
