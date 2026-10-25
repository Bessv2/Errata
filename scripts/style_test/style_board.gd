class_name StyleBoard
extends Resource
## Everything the style-test scene shows. Values live in data/style_test/board.tres.

## The five slots, left to right.
@export var slots: Array[StyleSlot] = []
## Fallback floor tile, used only if the ground slot has no candidates.
## Normally every slot stands on whichever ground candidate is showing.
@export var floor_tile: Texture2D
## Top-face offset for floor_tile (see StyleCandidate.ground_offset).
@export var floor_offset: float = 43.0
## Tint applied to floor tiles (matches the arena floor so placeholders look as in game).
@export var floor_tint: Color = Color(0.5, 0.5, 0.6)
## Reference swatches for the design doc's palette words. Not final: the approved
## style test sets the real palette.
@export var palette: PackedColorArray = PackedColorArray()
## Name under each swatch, same order as palette.
@export var palette_names: PackedStringArray = PackedStringArray()
