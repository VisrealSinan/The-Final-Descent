# The Final Descent

A single-player, top-down 2D dungeon crawler with RPG elements, made for Andrew, Davey, and Han's seven-day hackathon.

**Status:** All three heroes have a first Godot-ready sprite pack and a shared animation preview. Dungeon gameplay has not been implemented yet.

## How to play

Gameplay launch instructions will be added when the first playable dungeon build exists. The engine is Godot; the target platform remains to be decided. Chosen gameplay controls are **WASD to move** and **hold an arrow key to aim and repeatedly melee attack**, independently of movement. All three playable characters are melee-only; Visreal uses sword slashes. These gameplay controls are not implemented yet.

To inspect the character assets now, import `project.godot` in Godot 4 and press **F5**. Press **1** for Visreal, **2** for Han, or **3** for Ghalrym. Space pauses, Right steps frames while paused, R replays, and T changes the panel backdrop. Preview controls are not final game controls. The original standalone Visreal preview remains available.

Sprite packs and import instructions: [Visreal](assets/characters/visreal/README.md), [Han](assets/characters/han/README.md), [Ghalrym](assets/characters/ghalrym/README.md). Each includes 5 transparent sheets, 20 animations, 80 frames, a SpriteFrames resource, a visual scene, and atlas JSON. Tested with Godot 4.7.2.

The agreed game loop is:

1. Choose Visreal the Rogue, Ghalrym the Cat Druid, or Han the Bear Druid. Your chosen hero ventures alone.
2. Start on floor one and descend through six floors.
3. Each floor contains five rooms: one enemy-free spawn room and four rooms with enemies, including a floor boss within that room count.
4. Move and actively use class-based melee attacks. Enemy kills award XP.
5. Leveling increases stats for the remainder of the run.
6. Earn one equipment piece from each of the first five floor bosses, completing all five slots before floor six. The reward order remains to be chosen.
7. Face a sixth-floor challenge themed around something the selected class fears or dislikes; its details will be designed later.
8. On death, use the game-over screen to return to the main menu or restart from floor one.

There is no progression between runs in the initial version; earned equipment resets with the run. Visreal's shadow-and-poison skill kit is approved; enemies and bosses, the other heroes' skills, stats, further control behavior, floor-transition details, and the finale are still being designed.

## Design

- [Agreed game design](docs/GAME-DESIGN.md)
- [Visreal character brief](docs/characters/VISREAL.md)
- [Han character brief and concepts](docs/characters/HAN.md)
- [Ghalrym character brief and concepts](docs/characters/GHALRYM.md)
- [Official hackathon rules](Hackathon-Official-Rules.md)

Visreal's appearance, first sprite pack, and skill kit are approved: **Twin Slashes, Shadowstep, Venom Blades, and Nightshade**. His five equipment slots are **paired swords, armor, cape, mask, and trinket**; item effects are being designed. These gameplay systems are not implemented yet. Han's gnome-bear v3 and Ghalrym's human-faced catgirl v4 are the chosen references for their new sprite packs; their skills remain open.

## Hackathon window

Participant: Davey. Start: November 12, 2026, 8:45 p.m. America/New_York.
Finish: November 19, 2026, 8:45 p.m. America/New_York.

The human defines the game and approves major creative decisions. AI may refine ideas and execute agreed tasks. Overnight work is restricted to human-defined and approved issues and necessary supporting work.

## Tools used

- ChatGPT / Codex: planning, design documentation, and repository setup.
- Built-in OpenAI image generation: character concepts, revisions, and transparent sprite sheets for Visreal, Han, and Ghalrym.
- Godot 4.7.2: sprite resources, preview rendering, and import/playback validation.
- Git and GitHub: version control and project hosting.

Update this list as additional tools are actually used. The rules do not require a per-asset tool mapping.
