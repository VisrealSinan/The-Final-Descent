# Ghalrym: Godot sprite pack v1

Based on Ghalrym's human-faced catgirl v4 reference for **The Final Descent**. Built-in OpenAI image generation created the artwork; [exact prompts](prompts/) are included. Source PNG pixels are preserved; packaging only writes atlas metadata.

## Contents

Five transparent 1254 x 1254 PNG sheets: **80 frames, 20 animations**. Each sheet has four direction rows (south, west, east, north), with four chronological frames per row.

| Sheet | Frames per direction | Initial FPS | Loops |
| --- | --- | --- | --- |
| idle.png | 4 | 5 | Yes |
| walk.png | 4 | 8 | Yes |
| attack.png | 4 | 10 | No |
| hurt.png | 4 | 10 | No |
| death.png | 4 | 6 | No |

Names use `action_direction`: `walk_west`, `attack_south`, `death_north`, etc. The base attack is a clawed-hand swipe. These four-frame cycles and playback rates are first-pass visual defaults, not a finalized skill kit or combat balance.

## Drop into Godot

1. Extract the ZIP's `assets` folder into your project root, keeping `res://assets/characters/ghalrym/`.
2. Let Godot import the PNGs.
3. Drag `ghalrym_visual.tscn` into your scene. Its AnimatedSprite2D already uses `ghalrym_frames.tres`.
4. Scale the visual for your camera; the preview uses 0.43. The root represents the intended foot/ground anchor.

```gdscript
$GhalrymVisual/AnimatedSprite2D.play("walk_west")
$GhalrymVisual/AnimatedSprite2D.play("attack_south")
```

For an existing AnimatedSprite2D, assign the frames resource, keep `centered = true`, and set `offset = Vector2(0, -156)`.

Idle/walk loop. Attack/hurt play once; use `animation_finished` to select the next state. Death stops on its last frame. This visual scene has no movement controller, collision, hitbox, damage events, stats, or special-skill logic.

**No manual slicing needed.** Generated source spacing varies slightly. Use the supplied resource rather than a uniform-grid importer. Measured AtlasTexture regions and margins create **384 x 384 logical frames** with anchor **(192, 348)**. `ghalrym.atlas.json` provides matching source regions and placement offsets. Collapsed poses are measured individually so they can cross nominal grid guides without being clipped.

## Preview and checks

Open the repository's `project.godot` and press F5. **1 / 2 / 3** select Visreal / Han / Ghalrym. Space pauses, Right steps while paused, R replays, and T changes the panel backdrop. One-shot animations repeat periodically only in the preview.

Tested in Godot 4.7.2: imports, all frame bounds and sizes, scene loading, looping walk, final death frame, and rendered preview. `validation.json` records measured regions and cut checks using alpha above 25%. Four-frame cycles can be expanded after gameplay testing.

From the repository root, rebuild/check with:

```text
godot --headless --path . --editor --import
godot --headless --path . --script tools/build_character.gd -- ghalrym
godot --headless --path . --script tools/check_character.gd -- ghalrym
```

The builder reads images and writes resource/JSON metadata only. Prompts describe the intended art; metadata records actual generated image sizes and regions.
