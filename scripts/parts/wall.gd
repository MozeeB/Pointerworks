class_name Wall
extends Part
## Wall — kills any VirtualCursor that overlaps it. Red flash on death
## (handled by VirtualCursor.die("wall")).


func _ready() -> void:
	super()
	add_to_group(&"walls")


func apply_to_cursor(cursor: VirtualCursor) -> void:
	cursor.die(&"wall")
