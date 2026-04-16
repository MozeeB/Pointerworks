class_name PartData
extends Resource
## PartData — design-time data for a single placed part.
##
## Stored inside `LevelResource.part_placements[]` (Day 2). At runtime the
## Level scene reads this to instance the correct Part scene, place it, and
## orient it. All fields are value-typed — copy, don't mutate.

enum Type {
	EMITTER,
	WALL,
	TARGET,
	DEFLECTOR,
	SPLITTER,
	SPEED_MOD,
	TELEPORTER,
}


@export var type: Type = Type.WALL
## 0-3; each step = 90° CW. Ignored by rotationally-symmetric parts.
@export_range(0, 3) var rotation_steps: int = 0
## Meaning depends on type — SpeedMod: 0=×0.5 slow, 1=×2.0 fast.
## Teleporter: pair index (0 pairs with 0, 1 with 1, ...).
@export var variant: int = 0
## Palette color override. Defaults to FG_LIGHT; subclasses pick their own.
@export var palette_color: int = int(AppPalette.Swatch.FG_LIGHT)


## Return a new PartData with a mutated rotation — never mutate in place.
func with_rotation(new_rotation: int) -> PartData:
	var copy := PartData.new()
	copy.type = type
	copy.rotation_steps = posmod(new_rotation, 4)
	copy.variant = variant
	copy.palette_color = palette_color
	return copy
