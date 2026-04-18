extends Node3D
## Atmosphere3D — slow-rotating low-poly machinery backdrop.
##
## Used behind menu screens (main, level_select, credits) to add depth
## while keeping the 2D puzzle playfield focused. GL Compatibility safe
## (no PBR, just StandardMaterial3D albedo with the AppPalette).
##
## Performance: 5 meshes × 60 fps × no shadows = trivial cost on web.

const ROT_GEAR_LARGE := 0.35  # rad/s
const ROT_GEAR_SMALL := -0.6
const ROT_PISTON := 1.4
const ROT_BEAM := 0.18

@onready var _gear_large: MeshInstance3D = $GearLarge if has_node("GearLarge") else null
@onready var _gear_small: MeshInstance3D = $GearSmall if has_node("GearSmall") else null
@onready var _piston: MeshInstance3D = $Piston if has_node("Piston") else null
@onready var _beam: MeshInstance3D = $Beam if has_node("Beam") else null
@onready var _frame: MeshInstance3D = $Frame if has_node("Frame") else null

var _t: float = 0.0


func _ready() -> void:
	_apply_palette()
	var settings := get_node_or_null(^"/root/Settings")
	if settings != null:
		settings.settings_changed.connect(_apply_palette)


func _process(delta: float) -> void:
	_t += delta
	if _gear_large != null:
		_gear_large.rotation.z += ROT_GEAR_LARGE * delta
	if _gear_small != null:
		_gear_small.rotation.z += ROT_GEAR_SMALL * delta
	if _piston != null:
		# Piston bobs along Y instead of rotating.
		_piston.position.y = 0.4 * sin(_t * ROT_PISTON)
	if _beam != null:
		_beam.rotation.y += ROT_BEAM * delta
	if _frame != null:
		_frame.rotation.y += ROT_BEAM * 0.5 * delta


func _apply_palette() -> void:
	# Re-tint mesh albedos when colorblind toggles. Each mesh keeps its
	# baseline AppPalette swatch.
	_set_albedo(_gear_large, AppPalette.Swatch.EMITTER_AMBER)
	_set_albedo(_gear_small, AppPalette.Swatch.WALL_GREY)
	_set_albedo(_piston, AppPalette.Swatch.CURSOR_MAGENTA)
	_set_albedo(_beam, AppPalette.Swatch.TARGET_CYAN)
	_set_albedo(_frame, AppPalette.Swatch.MUTED_TEXT)


func _set_albedo(mesh: MeshInstance3D, swatch: int) -> void:
	if mesh == null:
		return
	var mat: StandardMaterial3D = mesh.get_active_material(0) as StandardMaterial3D
	if mat == null:
		mat = StandardMaterial3D.new()
		mesh.material_override = mat
	mat.albedo_color = AppPalette.get_color(swatch)
	# Slight emission so it stays visible against the dark bg without lighting.
	mat.emission_enabled = true
	mat.emission = mat.albedo_color * 0.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
