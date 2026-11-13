# The Final Descent

A single-player, top-down 2D dungeon crawler with RPG elements, made for Andrew, Davey, and Han's seven-day hackathon.

**Status:** Visreal's first Godot-ready sprite pack and animation preview are available. Dungeon gameplay has not been implemented yet.

## How to play

Gameplay launch instructions and controls will be added when the first playable dungeon build exists. The engine is Godot; the target platform remains to be decided.

To inspect the character assets now, import `project.godot` in Godot 4 and press **F6** in `previews/visreal_preview.tscn`, or **F5** to run the configured preview. Space pauses, Right steps frames while paused, R replays, and T changes the backdrop. Preview controls are not final game controls.

[Sprite pack and Godot import instructions](assets/characters/visreal/README.md). Tested with Godot 4.7.2.

The agreed game loop is:

1. Choose Visreal the Rogue, Ghalrym the Cat Druid, or Han the Bear Druid. Your chosen hero ventures alone.
2. Start on floor one and survive as many floors as possible.
3. Each floor contains five rooms: one enemy-free spawn room and four rooms with enemies.
4. Move and actively use class-based attacks or spells. Enemy kills award XP.
5. Leveling increases stats for the remainder of the run.
6. On death, use the game-over screen to return to the main menu or restart from floor one.

There is no progression between runs in the initial version. Enemies, skills, stats, controls, and floor-transition details are still being designed.

## Design

- [Agreed game design](docs/GAME-DESIGN.md)
- [Visreal character brief](docs/characters/VISREAL.md)
- [Han character brief and concepts](docs/characters/HAN.md)
- [Official hackathon rules](Hackathon-Official-Rules.md)

Visreal's appearance and first sprite pack are approved. Han's visuals are next at Davey's request. Ghalrym's visuals and character skills remain to be defined before refining gameplay.

## Hackathon window

Participant: Davey. Start: November 12, 2026, 8:45 p.m. America/New_York.
Finish: November 19, 2026, 8:45 p.m. America/New_York.

The human defines the game and approves major creative decisions. AI may refine ideas and execute agreed tasks. Overnight work is restricted to human-defined and approved issues and necessary supporting work.

## Tools used

- ChatGPT / Codex: planning, design documentation, and repository setup.
- Built-in OpenAI image generation: character concepts and revisions for Visreal and Han, plus Visreal's transparent sprite sheets.
- Godot 4.7.2: sprite resources, preview rendering, and import/playback validation.
- Git and GitHub: version control and project hosting.

Update this list as additional tools are actually used. The rules do not require a per-asset tool mapping.
