# The Final Descent: agreed design

This file records decisions made by Davey. Suggestions are not approved features until Davey chooses them.

## Core

- Single-player, top-down 2D dungeon crawler with RPG elements.
- Players select one of three heroes; the chosen hero ventures alone.
- Direct movement and active class-based melee attacks. All three playable characters are melee-only, as chosen by Davey for fairness.
- A run spans six floors. Davey replaced the earlier endless-survival direction with a defined six-floor descent.
- Exactly five rooms per floor: an enemy-free spawn room plus four rooms containing enemies.
- Dark fantasy, World of Warcraft-inspired parody art direction.
- Engine: Godot, selected by Davey. The first deliverable is a character asset preview, not the playable dungeon crawler.

## Floors and boss rewards

- Each floor has a boss. Boss encounters fit within the existing five-room-per-floor limit; their exact placement and encounter designs remain open.
- Bosses drop one equipment piece per floor. The first five floors provide the five pieces needed to complete the hero's equipment before floor six.
- Davey chose random reward order with no duplicates: the first five bosses each drop a different equipment slot, completing all five slots before floor six.
- Implementation plan: shuffle the five reward slots once when a run starts and consume one entry for each of the first five boss rewards. A new run gets a fresh shuffle. This logic is not implemented yet.
- Visreal's paired swords count as a single equipment reward for his paired-swords slot.
- Floor six is the final floor, themed around something the selected class fears or dislikes. Davey explicitly deferred its detailed design.
- The sixth boss's reward, the victory sequence, and whether Han and Ghalrym receive distinct final-floor variants despite both being Druids remain open. No specific fears, enemies, or final-floor mechanics have been chosen.
- Starting equipment, reward collection/equipping behavior, and item names remain open. All five of Visreal's equipment effects are approved below; Han's and Ghalrym's equipment effects remain open. These decisions do not remove the characters' approved visual outfits or weapons.

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
- Equipment earned during a run does not carry into a new run.
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

Davey also chose five equipment slots for Visreal, with both swords occupying one slot as a set, and approved all five effects:

- **Paired swords:** poison and shadow damage through melee hits, replacing the proposed generic melee-damage bonus.
- **Armor:** reduced incoming damage.
- **Cape:** reduced Shadowstep cooldown.
- **Mask:** increased poison damage.
- **Trinket:** increased shadow bonus damage on the slash empowered by Shadowstep.

Item names remain working proposals in [Visreal's character brief](characters/VISREAL.md#equipment). Equipment comes from the floor bosses in random order without duplicates as described above. Skill bindings, poison behavior and stacking, and equipment interactions with Venom Blades and Nightshade remain open. Davey explicitly deferred numerical balance until later; damage values, cooldowns, durations, and percentages will be tuned during playtesting. These mechanics are agreed design, not implemented gameplay.

### Ghalrym

A Druid who chooses feline form over all other forms and rests in it. He loves AI and anime cat girls, and would do anything to help his friends and save all the cat girls in the world. Davey refined the visual direction to a catgirl druid form and requested a human face. V4 is the sprite-production reference; see [Ghalrym's visual concepts](characters/GHALRYM.md). Skills are not yet defined.

### Han

A Druid who chooses bear form and enjoys being a caked-up bear. Davey approved the gnome-styled v3 concept. See [Han's approved visual reference](characters/HAN.md). Skills are not yet defined.

## Design sequence

1. Visreal's appearance and initial Godot sprite pack are approved.
2. Han's gnome-styled bear concept v3 is approved, and its first Godot sprite pack is built.
3. Ghalrym's human-faced catgirl v4 is the production reference, and its first Godot sprite pack is built.
4. Visreal's shadow-and-poison starter kit, five equipment slots, and all five equipment effects are approved. Numerical balance is deferred; Han's and Ghalrym's skill kits and equipment remain open.
5. Six floors and boss equipment drops in random order without duplicates are approved, with five pieces earned before the class-themed final floor. Detailed final-floor design is deferred at Davey's request.
6. Refine each character's gameplay after appearance and skills are settled.

## Decisions still open

- Target platform and distribution method.
- Diagonal aiming and special-ability bindings; movement, attack key groups, and hold-to-repeat are decided above.
- Han's and Ghalrym's skills; all characters' cooldowns, resources, and numerical stats; Visreal's detailed poison behavior.
- Equipment slots and effects for Han and Ghalrym; item names, starting gear, collection/equipping behavior, and any character-specific restrictions. Boss drops, random reward order without duplicates, and Visreal's five slots and effects are decided above.
- Enemy and boss types, behavior, and difficulty scaling.
- Room connections, floor layouts, the condition for descending, and victory presentation.
- Floor-six fears/dislikes, class or character variants, encounter details, and its boss reward; deferred for later discussion.
- Specific art treatment, animation requirements, audio, and UI details.

Earlier assistant suggestions such as shadow rescue, healing purrs, an AI companion, and cheek quake are unapproved ideas, not requirements.

## Working within the rules

Davey supplies the creative direction. AI can make routine implementation decisions within agreed scope. Major unresolved design decisions and scope expansion go back to Davey. Overnight tasks must be human-defined and approved.

Completed work: repository setup, character concepts, and first Godot-ready sprite packs for Visreal, Han, and Ghalrym with import resources and a shared animation preview. Davey explicitly requested Han and Ghalrym's sprite sheets after the visual revisions. This is not authorization to invent all remaining game systems.

Visreal's skill kit and equipment effects are now approved, with numerical balance explicitly deferred. Basic movement, melee hit detection, and combat have not yet been implemented. A small playable combat test is the next proposed implementation milestone to evaluate these mechanics; full dungeon and progression implementation remain later work. Han's and Ghalrym's kits and equipment are still open design work.
