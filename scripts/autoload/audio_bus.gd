extends Node
## AudioBus — central SFX/music player.
##
## Pool of 8 AudioStreamPlayer nodes routed to the "SFX" bus for
## overlapping one-shots, plus a single music player on the "Music"
## bus. Music is primed (started) on the first user gesture to
## satisfy browser autoplay policy.

const SFX_POOL_SIZE: int = 8
const SFX_DIR: String = "res://audio/sfx/"
const MUSIC_PATH: String = "res://audio/music/factory_loop.ogg"

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cursor: int = 0
var _music_player: AudioStreamPlayer
var _sfx_cache: Dictionary = {}  # name (String) → AudioStream
var _music_primed: bool = false


func _ready() -> void:
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.autoplay = false
	add_child(_music_player)


func play_sfx(sfx_name: String) -> void:
	var stream: AudioStream = _get_sfx(sfx_name)
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_sfx_cursor]
	_sfx_cursor = (_sfx_cursor + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.play()


func prime_music() -> void:
	# Call once from the first user-gesture (PlayButton click) to start
	# the music loop. Subsequent calls are no-ops.
	if _music_primed:
		return
	if not ResourceLoader.exists(MUSIC_PATH):
		return
	var stream: AudioStream = load(MUSIC_PATH)
	if stream == null:
		return
	_music_player.stream = stream
	# Enable loop if the stream supports it.
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	_music_player.play()
	_music_primed = true


func stop_music() -> void:
	_music_player.stop()


func _get_sfx(sfx_name: String) -> AudioStream:
	if _sfx_cache.has(sfx_name):
		return _sfx_cache[sfx_name]
	var path: String = "%s%s.ogg" % [SFX_DIR, sfx_name]
	if not ResourceLoader.exists(path):
		return null
	var stream: AudioStream = load(path)
	_sfx_cache[sfx_name] = stream
	return stream
