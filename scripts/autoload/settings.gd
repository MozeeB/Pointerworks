extends Node
## Settings — runtime user preferences (volume, fullscreen, colorblind).
##
## Persisted via ConfigFile at `user://settings.cfg`. On any mutation,
## emits `settings_changed` so subscribers (Polygon2Ds for colorblind,
## AudioServer for volume) can react.

signal settings_changed

const SAVE_PATH := "user://settings.cfg"
const CURRENT_VERSION := 1

var master_vol: float = 1.0
var music_vol: float = 0.8
var sfx_vol: float = 1.0
var fullscreen: bool = false
var colorblind_palette: bool = false


func _ready() -> void:
	load_settings()
	_apply_volumes()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	var version: int = cfg.get_value("meta", "version", 0)
	if version != CURRENT_VERSION:
		return
	master_vol = cfg.get_value("audio", "master", 1.0)
	music_vol = cfg.get_value("audio", "music", 0.8)
	sfx_vol = cfg.get_value("audio", "sfx", 1.0)
	fullscreen = cfg.get_value("display", "fullscreen", false)
	colorblind_palette = cfg.get_value("display", "colorblind", false)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", CURRENT_VERSION)
	cfg.set_value("audio", "master", master_vol)
	cfg.set_value("audio", "music", music_vol)
	cfg.set_value("audio", "sfx", sfx_vol)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("display", "colorblind", colorblind_palette)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_error("Settings: failed to save (err=%d)" % err)


func set_master_vol(v: float) -> void:
	master_vol = clampf(v, 0.0, 1.0)
	_apply_volumes()
	settings_changed.emit()
	save_settings()


func set_music_vol(v: float) -> void:
	music_vol = clampf(v, 0.0, 1.0)
	_apply_volumes()
	settings_changed.emit()
	save_settings()


func set_sfx_vol(v: float) -> void:
	sfx_vol = clampf(v, 0.0, 1.0)
	_apply_volumes()
	settings_changed.emit()
	save_settings()


func set_colorblind(enabled: bool) -> void:
	if colorblind_palette == enabled:
		return
	colorblind_palette = enabled
	settings_changed.emit()
	save_settings()


func set_fullscreen(enabled: bool) -> void:
	if fullscreen == enabled:
		return
	fullscreen = enabled
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	settings_changed.emit()
	save_settings()


func _apply_volumes() -> void:
	_set_bus_volume("Master", master_vol)
	_set_bus_volume("Music", music_vol)
	_set_bus_volume("SFX", sfx_vol)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	# Avoid -inf dB on 0 volume — mute the bus instead.
	if linear <= 0.0001:
		AudioServer.set_bus_mute(idx, true)
		return
	AudioServer.set_bus_mute(idx, false)
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
