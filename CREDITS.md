# Credits

Every asset in `assets/` is listed here: name, creator, source URL, licence, and what it's used for.
Licence rules are in CLAUDE.md ("Approved asset sources"). CC-BY assets must include the credit line the licence requires.
Remove a row when its asset is replaced.

## Art

| Name | Files | Creator | Source | Licence | Used for | Placeholder? |
|---|---|---|---|---|---|---|
| Isometric Miniature Dungeon (two floor tiles) | `assets/art/placeholder/kenney_dungeon/*.png` (scaled to 1/4 size) | Kenney (kenney.nl) | [kenney.nl](https://kenney.nl/assets/isometric-miniature-dungeon) | CC0 1.0 | Placeholder comparison on the style-test board (no longer in the arena) | Yes |
| Isometric Miniature Dungeon (Male character) | `assets/art/placeholder/kenney_hero/*.png` (idle + run, 8 directions, scaled to 1/4 size) | Kenney (kenney.nl) | [kenney.nl](https://kenney.nl/assets/isometric-miniature-dungeon) | CC0 1.0 | Placeholder comparison on the style-test board (no longer the in-game hero) | Yes |
| Hero A (idle + run, 8 directions) | `assets/art/hero/**` | Generated with PixelLab for Errata (2026-10-27); approved by Geordon | [pixellab.ai](https://pixellab.ai) | PixelLab terms of service ([pixellab.ai/termsofservice](https://pixellab.ai/termsofservice)); check commercial-use rights for the plan used before shipping | In-game hero sprite | No |
| Void Mite #2 (small, 28px) | `assets/art/enemies/void_mite.png` | Generated with PixelLab for Errata (2026-10-25), downscaled locally; approved by Geordon (2026-10-27) | [pixellab.ai](https://pixellab.ai) | PixelLab terms of service ([pixellab.ai/termsofservice](https://pixellab.ai/termsofservice)); check commercial-use rights for the plan used before shipping | In-game Void Mite sprite | No |
| Ruined wall block | `assets/art/world/walls/ruin_wall.png` | Generated with PixelLab for Errata (2026-10-31); approved by Geordon (2026-10-31) | [pixellab.ai](https://pixellab.ai) | PixelLab terms of service ([pixellab.ai/termsofservice](https://pixellab.ai/termsofservice)); check commercial-use rights for the plan used before shipping | Arena back walls | No |
| Ground tiles (flagstone, ash, and their softened versions) | `assets/art/world/ground/*.png` | Generated with PixelLab for Errata (2026-10-25); softened locally with `tools/art/soften_tile.gd` (2026-10-28, 2026-10-31); approved by Geordon | [pixellab.ai](https://pixellab.ai) | PixelLab terms of service ([pixellab.ai/termsofservice](https://pixellab.ai/termsofservice)); check commercial-use rights for the plan used before shipping | Arena floor | No |
| Style-test candidates (hero A/B, 6 Void Mites, 5 rift-touched, 5 anvils, 7 ground tiles, 3 wall blocks) | `assets/art/style_test/candidates/**` | Generated with PixelLab for Errata (2026-10-25, 2026-10-28 and 2026-10-31) | [pixellab.ai](https://pixellab.ai) | PixelLab terms of service ([pixellab.ai/termsofservice](https://pixellab.ai/termsofservice)); check commercial-use rights for the plan used before shipping | Style-test board only, not in the game | Candidate (awaiting approval) |

## Audio

| Name | Files | Creator | Source | Licence | Used for | Placeholder? |
|---|---|---|---|---|---|---|
| Interface Sounds (`confirmation_002`) | `assets/audio/placeholder/kenney_interface/confirmation_002.wav` | Kenney (kenney.nl); Godot packaging by Calinou | [Godot Asset Library #794](https://godotengine.org/asset-library/asset/794) | CC0 1.0 | "Respawn nearby" button | Yes |
| Small Sound Kit (Mgc_Fire_Throw_01, Impact_Guts_Gore_01, Blood_Bone_Smash_01, Breaking_Bones_01, Blood_01, Drs_Wood_DoubleDoor_Close_01, Drn_Alien_01, Mgc_Glacier_Cast_01, S_Concrete_Mono_1-4) | `assets/audio/sfx/small_sound_kit/*.wav` (trimmed; Cleave swing, hits, door thump and drone reshaped with `tools/audio/shape_sounds.gd`) | DailySounds | [dailysounds.org](https://dailysounds.org) (added by Geordon via `_incoming`) | CC BY 4.0 (per Geordon) | Cleave swing (low fire whoosh), Cleave hit (bone impact over a low door thump), mite wind-up (drone), hero hurt/death/respawn, footsteps | Yes |
| Real Foley SFX (Knuckles_Cracking, Stick_Snap) | `assets/audio/sfx/dailysounds/*.wav` (trimmed; snap slowed with `tools/audio/shape_sounds.gd`) | DailySounds | [dailysounds.org](https://dailysounds.org) | CC BY 4.0 | Mite death (crunch, snap) | Yes |

**Required CC BY 4.0 credits** (show these in the game's credits screen):
- Sound effects by DailySounds (https://dailysounds.org), CC BY 4.0. Clips trimmed.
- Small Sound Kit by DailySounds (https://dailysounds.org), CC BY 4.0. Clips trimmed.

## Fonts

| Name | Files | Creator | Source | Licence | Used for | Placeholder? |
|---|---|---|---|---|---|---|
