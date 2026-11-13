# The Final Descent: agreed design

This file records decisions made by Davey. Suggestions are not approved features until Davey chooses them.

## Core

- Single-player, top-down 2D dungeon crawler with RPG elements.
- Players select one of three heroes; the chosen hero ventures alone.
- Direct movement and active class-based melee attacks. All three playable characters are melee-only, as chosen by Davey for fairness.
- Survive as many floors of the void as possible; no fixed final floor has been specified.
- Exactly five rooms per floor: an enemy-free spawn room plus four rooms containing enemies.
- Dark fantasy, World of Warcraft-inspired parody art direction.
- Engine: Godot, selected by Davey. The first deliverable is a character asset preview, not the playable dungeon crawler.

## Chosen gameplay controls

- Movement: W up, A left, S down, D right.
- Aim and melee attack: arrow keys in the corresponding direction.
- Movement and attack direction are independent, allowing movement one way while attacking another.
- This replaces the earlier assistant suggestion of mouse aiming and left-click attacks.
- Holding an arrow key repeatedly performs the basic melee attack in that direction. Davey selected hold-to-repeat for ease of play; individual key presses are not required for successive attacks.
- These mappings are agreed design, not yet implemented gameplay. Diagonal aiming and special-ability bindings remain to be decided. Repeat cadence will follow the attack timing once it is defined.
- Visreal's basic attack is a close-range sword slash. Player attacks are melee-only; no ranged player attacks. This does not decide enemy attack types, which remain open.
- Melee-only does not yet prescribe equal reach, damage, or attack speed. Those values remain open; Visreal's approved abilities are recorded below, and Han's and Ghalrym's kits remain to be designed with Davey.

## Progression and death

- Enemy kills grant XP during the run.
- Leveling increases stats for the rest of that run.
- No outside meta-progression in the initial version.
- Death leads to a game-over screen with options to return to the main menu or restart from floor one.
- Stat definitions, values, XP curves, and level-up details will be defined later.

## Characters

### Visreal

A gamer who is naturally a Rogue. He has a darker, self-sacrificing side and is prone to sneaking away to save his friends rather than himself. See [his appearance brief](characters/VISREAL.md).

Davey chose shadow- and poison-powered melee and approved this kit:

- **Twin Slashes:** repeating close-range dual-sword attacks using the agreed arrow-key controls.
- **Shadowstep:** a short dash in the aim direction that empowers the next sword slash with shadow damage.
- **Venom Blades:** temporarily coats the swords so melee hits poison enemies, dealing damage over time.
- **Nightshade:** a passive that gives shadow-empowered strikes extra damage against poisoned enemies.

Davey also chose five equipment slots for Visreal: **paired swords, armor, cape, mask, and trinket**, with both swords occupying one slot as a set. Item names and bonuses are still proposals in [Visreal's character brief](characters/VISREAL.md#equipment). Skill bindings, poison stacking, timing, numerical balance, and equipment acquisition remain open. These mechanics are agreed design, not implemented gameplay.

### Ghalrym

A Druid who chooses feline form over all other forms and rests in it. He loves AI and anime cat girls, and would do anything to help his friends and save all the cat girls in the world. Davey refined the visual direction to a catgirl druid form and requested a human face. V4 is the sprite-production reference; see [Ghalrym's visual concepts](characters/GHALRYM.md). Skills are not yet defined.

### Han

A Druid who chooses bear form and enjoys being a caked-up bear. Davey approved the gnome-styled v3 concept. See [Han's approved visual reference](characters/HAN.md). Skills are not yet defined.

## Design sequence

1. Visreal's appearance and initial Godot sprite pack are approved.
2. Han's gnome-styled bear concept v3 is approved, and its first Godot sprite pack is built.
3. Ghalrym's human-faced catgirl v4 is the production reference, and its first Godot sprite pack is built.
4. Visreal's shadow-and-poison starter kit and five equipment slots are approved. Define his equipment effects next; Han's and Ghalrym's skill kits remain open.
5. Refine each character's gameplay after appearance and skills are settled.

## Decisions still open

- Target platform and distribution method.
- Diagonal aiming and special-ability bindings; movement, attack key groups, and hold-to-repeat are decided above.
- Han's and Ghalrym's skills; all characters' cooldowns, resources, and numerical stats; Visreal's detailed poison behavior.
- Equipment slots for Han and Ghalrym; item effects, acquisition, and any character-specific restrictions. Visreal's five slots are decided above.
- Enemy types, behavior, and difficulty scaling.
- Room connections, floor layouts, and the condition for descending.
- Specific art treatment, animation requirements, audio, and UI details.

Earlier assistant suggestions such as shadow rescue, healing purrs, an AI companion, and cheek quake are unapproved ideas, not requirements.

## Working within the rules

Davey supplies the creative direction. AI can make routine implementation decisions within agreed scope. Major unresolved design decisions and scope expansion go back to Davey. Overnight tasks must be human-defined and approved.

Completed work: repository setup, character concepts, and first Godot-ready sprite packs for Visreal, Han, and Ghalrym with import resources and a shared animation preview. Davey explicitly requested Han and Ghalrym's sprite sheets after the visual revisions. This is not authorization to invent all remaining game systems.

Next requested design work: Visreal's equipment names and effects, following approval of his skill kit and equipment slots. Basic movement, melee hit detection, and combat have not yet been implemented. A small playable combat test is the next proposed implementation milestone; full dungeon and progression implementation remain later work.
