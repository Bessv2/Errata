class_name StyleCandidate
extends Resource
## One piece of candidate art for a style-test slot. Fill exactly one of
## texture / frames / scene. Lives inside data/style_test/board.tres.

## Shown under the slot, e.g. "PixelLab v2 (bruised purple)" or "placeholder".
@export var label: String = ""
## A still image (sprite or a single ground tile).
@export var texture: Texture2D
## An animated sprite; plays its first animation on a loop.
@export var frames: SpriteFrames
## A whole scene (used for art drawn in code, like the current Void Mite placeholder).
@export var scene: PackedScene
## Feet offset: how far up from the image's centre the feet/ground contact sits (pixels).
@export var feet_offset: float = 0.0
## Ground tiles only: how far below the image's centre the middle of the tile's
## top face sits (pixels). Kenney tiles: 43. PixelLab 64px thin tiles: 6.
@export var ground_offset: float = 0.0
## Ground tiles only: tint with the board's floor_tint (true for the Kenney
## placeholders, which are tinted the same way in the arena).
@export var tint_as_floor: bool = false
