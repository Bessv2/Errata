# Errata — Project Rules for Claude Code

Errata is a 2D isometric pixel-art ARPG set in a cosmic horror world, with Helltide-style open-world farming, boss and loot dungeons, an idle camp, and prestige (Ascension + Rebirth). Built in **Godot 4 with GDScript**.

**The design doc is the source of truth:** https://claude.ai/artifact/EEYSawbgVL4HjA1mriqBY8
If a request conflicts with the design doc, stop and say so before writing code.

---

## Who you're working with

Geordon is the designer and owner. He is learning to code from scratch and is an experienced IT engineer (not a programmer).

- He makes design decisions. You implement them. Never invent features, systems, or content that aren't in the design doc. If something seems missing, suggest it and wait for approval.
- After every change, explain in plain English: what you changed, which files, and why. Keep it short.
- When you write a new script, add brief comments explaining what each section does.
- If he approves something without asking questions, that's not a signal to go bigger. Stay in scope.

## The current milestone

Work only on the current milestone. Do not start the next one until he says the current one is done.

1. **Feel** ← CURRENT: one hero, one enemy type, one arena. Movement, Cleave, aim assist, hit-stop, knockback, screen shake, sound. Working on keyboard/mouse, controller, and touch. First APK + browser build.
2. **Zone**: Observatory Ruins slice, 3 monster types (one rift-touched), dense spawning, rift surge event.
3. **Loot**: 3 base item types, tiered affixes, rarity colors, Cleave + Whirlwind gems, The Inevitable Anvil.
4. **Dungeon + boss**: one key-gated loot dungeon, the Head Astronomer (2–3 attack patterns).
5. **Camp**: forge + one research building on real-time timers.
6. **Ascension**: beating the boss unlocks world tier 2.

Update the CURRENT marker only when Geordon says so.

## Polish bar (every milestone)

A milestone is not done until:
- Every player action has visual AND audio feedback.
- No placeholder art remains in that milestone's content.
- Balance numbers pass a simulation run (see Balance below).
- Nothing exists that isn't in the design doc.

Feel over features. A small thing that feels great beats a big thing that feels thrown together.

## Tone rules

- The world is played straight: cosmic horror, dread, decay. Cold desaturated palette (bruised purples, bone, rust, sickly green).
- Comedy appears ONLY through tagged sources: `rift_touched` monsters and goofy uniques/affixes. It reads as reality misprinting, not a wink at the player.
- No pop-culture references, no fourth-wall breaks, no meme text in UI.

## Technical rules

### Engine and platforms
- Godot 4, GDScript only (no C#). Use static typing (`var hp: int = 10`, typed function args and returns).
- Renderer: **Compatibility** (required for the browser build and best for mobile).
- Targets: PC (main), Android APK, and Web (HTML5). Every milestone must run on all three.
- Performance: must hold a playable frame rate in the browser build on a mid-range phone. Put monster-density and particle caps in config, per platform.

### Input and aiming
- All input goes through ONE input/aim layer (`scripts/input/`). Gameplay code asks "where is the player aiming?" and never reads devices directly.
- Supported: WASD + mouse, controller, touch (virtual joystick + skill buttons). Click-to-move is out of scope for now.
- Aim assist lives in the aim layer: soft target lock + snapping toward nearby enemies for controller and touch, off or minimal for mouse. Tunables in data.
- No skill may require pixel-precise aiming.

### Data-driven design
All tunable numbers live in data files, never hard-coded in scripts:
- `data/` holds JSON or Godot `.tres` resources: stats, skills, monsters, affixes, drop tables, timers, prestige costs.
- Scripts read from data. Rebalancing should never require editing a script.

### Balance
- `tools/sim/` holds headless balance simulations (e.g. 10,000 fights, 10,000 drops, idle curve projections).
- Run the relevant sim before asking Geordon to playtest any numbers change, and summarize the results in plain English.

### Architecture
- Keep game state separate from input and UI, so co-op could be added later.
- Prefer small scenes and small scripts. One responsibility per script.
- Use signals for communication between systems instead of reaching across the tree.
- Ask before adding any plugin, addon, or external dependency.

### Folder layout
```
scenes/        # .tscn files, grouped by feature (player/, enemies/, ui/, world/)
scripts/       # .gd files mirroring scenes/, plus input/ and systems/
data/          # tunables: skills, monsters, items, affixes, drop tables
assets/        # art/, audio/, fonts/  (track the license of every asset in CREDITS.md)
tools/sim/     # balance simulations
tests/         # automated tests
```

### Art and audio
- 2D isometric, 2:1 tiles. One character resolution and one palette for everything (set by the approved style test).
- Placeholders: CC0 or CC-BY (with the required credit in `CREDITS.md`), e.g. Kenney. Log every asset and its license in `CREDITS.md`.
- Never use art, names, or text from Diablo, Path of Exile, or any other game.

### Approved asset sources
You may pull assets from these sources without asking, as long as the rules below are met:
- itch.io free game assets: https://itch.io/game-assets/free/tag-godot
- The Godot Asset Library: https://godotengine.org/asset-library/asset

Rules:
- Art, audio and fonts licensed CC0: use freely.
- CC-BY: allowed, but add the required credit to CREDITS.md.
- Any other license (non-commercial, no-redistribution, custom, or no license stated): do not use. Ask first.
- Log every asset in CREDITS.md: name, creator, source URL, license, and what it's used for.
- Asset packs must only contain images, audio, fonts or Godot resources. If a download contains an .exe, installer or script you didn't expect, delete it and tell me.
- Everything must match the art spec (isometric, one character resolution, one palette). Don't mix styles just because something is free.
- Godot Asset Library plugins/addons are code, not assets: still ask before installing any of them, and explain what it does and why we need it.

### The `_incoming` folder
`C:\Godot\errata\_incoming\` holds assets Geordon has bought or downloaded himself. Everything in it is cleared for use; no licence approval needed. The other rules still apply:
- Log every asset you use in CREDITS.md: name, creator, where it came from, licence (or "purchased"), and what it's used for. If the files don't say who made it or what the licence is, ask Geordon when you log it.
- Check the contents: only images, audio, fonts or Godot resources get copied. If a pack contains an .exe, installer or script, don't copy it and tell him.
- Everything must still match the art spec. Don't use something just because it's in the folder.
- Copy only the files actually used into `assets/`. The folder itself is never committed (it's in `.gitignore`).

## Workflow

1. Before starting, restate the task in one or two sentences and name the files you expect to touch.
2. Make the change in small steps. Run the project (via the Godot MCP or `godot --headless`) and fix any errors before reporting back.
3. Check the polish bar items that apply.
4. Commit with a clear message after each working step (e.g. `Add hit-stop to Cleave`), so any bad change is one revert away.
5. Explain what changed in plain English.

If you're unsure whether something is in scope, ask. Do not guess big.
