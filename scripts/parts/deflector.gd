class_name Deflector
extends Part
## Deflector — rotates incoming cursor velocity by 90° CW.
##
## `rotation_steps` (0-3) adjusts which of the four "facings" the deflector
## uses, so a single Deflector can be placed in 4 orientations. The deflect
## angle itself is always +90° CW relative to the deflector's rotation.

func _ready() -> void:
	super()


func apply_to_cursor(cursor: VirtualCursor) -> void:
	# Each time a cursor passes through, rotate its velocity +90° CW plus
	# whatever the deflector's own rotation_steps (0-3) implies. Keep the speed.
	var steps: int = _get_rotation_steps()
	# Base rotation of 90° CW (π/2). `rotation_steps` adds extra quarter-turns.
	var angle: float = (PI * 0.5) + (steps * PI * 0.5)
	cursor.velocity = cursor.velocity.rotated(angle)
	# Re-align cursor to grid center to avoid drift after multiple deflects.
	cursor.global_position = global_position
	var audio := get_node_or_null(^"/root/AudioBus")
	if audio != null:
		audio.call(&"play_sfx", &"deflect")


func _get_rotation_steps() -> int:
	# Prefer PartData (authoritative once Level.tres drives placement).
	# Fall back to the Node2D rotation for hand-placed dev scenes.
	if data != null:
		return data.rotation_steps
	return posmod(int(round(rotation / (PI * 0.5))), 4)
