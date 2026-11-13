# Visreal: Godot sprite pack v1

Based on the approved v3 concept for **The Final Descent**. All artwork was generated with built-in OpenAI image generation; exact prompts are in [prompts](prompts/). PNGs retain their original transparent pixels. Godot atlas regions and margins handle slicing and alignment.

## Contents

Five transparent PNG sheets, each 1254 x 1254 pixels. Each has four direction rows (south, west, east, north) and four chronological frames per row: **80 frames / 20 animations**.

| Sheet | Animation names | Frames per direction | Initial FPS | Loops |
| --- | --- | --- | --- | --- |
| idle.png | idle_south / idle_west / idle_east / idle_north | 4 | 5 | Yes |
| walk.png | walk_south / walk_west / walk_east / walk_north | 4 | 8 | Yes |
| attack.png | attack_south / attack_west / attack_east / attack_north | 4 | 10 | No |
| hurt.png | hurt_south / hurt_west / hurt_east / hurt_north | 4 | 10 | No |
| death.png | death_south / death_west / death_east / death_north | 4 | 6 | No |

Frame rates are starting animation settings, not gameplay balance. Attack art depicts a basic sword strike; special skills are not yet designed.

## Drop into Godot

1. Keep this entire folder at `res://assets/characters/visreal/` in your Godot 4 project. If using the ZIP, extract its `assets` directory into the project root.
2. Allow Godot to import the PNGs.
3. Drag `visreal_visual.tscn` into a scene. It already contains an `AnimatedSprite2D` with `visreal_frames.tres` assigned and idle_south playing.
4. Scale the visual to suit the game camera. The preview uses scale 0.43. The root origin is the intended foot anchor; there is no collision body or gameplay code in this visual scene.

To use an existing AnimatedSprite2D, assign `visreal_frames.tres` to its Sprite Frames property and set `offset = Vector2(0, -156)` with `centered = true`.

```gdscript
$VisrealVisual/AnimatedSprite2D.play("walk_west")
$VisrealVisual/AnimatedSprite2D.play("attack_south")
```

Use `animation_finished` to return from attack/hurt to your chosen state. Death deliberately stops on the final frame. Gameplay code should choose an animation when state changes; avoid resetting `frame` every update.

**No manual slicing required.** The generated source PNGs have small spacing variations, so do not divide them with a uniform-grid importer. The supplied `SpriteFrames` resource uses measured regions, bleed clipping, and margins to provide a consistent **384 x 384 logical frame canvas** with foot anchor **(192, 348)**. `visreal.atlas.json` contains matching pixel regions and placement offsets for other importers. PNGs are not resized or repainted by the packaging code.

## Preview and verification

Open the repository's `project.godot` and press F5. The preview shows all twenty animations together. Space pauses; Right steps one frame while paused; R replays; T switches the background tone. Non-looping animations replay periodically only in the preview.

Tested in Godot 4.7.2: resource import, all 80 frame regions and logical sizes, scene loading, death termination, and looping walk playback. `validation.json` records the measured sheet boundaries. A zero count means no pixels with alpha above 25% lie on the selected row/column cuts; it is not a claim of perfect hand-drawn animation.

This is a first usable four-frame animation pack. More in-between frames and any skill-specific effects can be added after gameplay testing. No XP/stat logic, hitboxes, damage events, movement controller, or skill design is included in these visual assets.

## Rebuild resources

From the repository root with a Godot executable on PATH:

```text
godot --headless --path . --editor --import
godot --headless --path . --script tools/build_visreal.gd
godot --headless --path . --script tools/check_visreal.gd
```

The builder reads the sheets and writes resource/JSON metadata only. Art edits should use the approved reference and the image-generation workflow.

Godot references: [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html), [AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html), [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html).
