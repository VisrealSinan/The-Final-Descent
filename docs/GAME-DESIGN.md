# The Final Descent: agreed design

This file records decisions made by Davey. Suggestions are not approved features until Davey chooses them.

## Core

- Single-player, top-down 2D dungeon crawler with RPG elements.
- Players select one of three heroes; the chosen hero ventures alone.
- All three are playable. Davey chose bear swipes for Han and cat claws for Ghalrym and deferred their special skills. For this first build, Han has a broad, slower strike and more health. Ghalrym moves and strikes faster. Both Druids use the existing court on floor six and gain a temporary +2 melee damage per guardian reward.
- Direct movement and active class-based melee attacks. All three playable characters are melee-only, as chosen by Davey for fairness.
- A run spans six floors. Davey replaced the earlier endless-survival direction with a defined six-floor descent.
- Exactly five rooms per floor: an enemy-free spawn room plus four rooms containing enemies.
- Dark fantasy, World of Warcraft-inspired parody art direction.
- Engine: Godot, selected by Davey. The game opens with hero selection for the six-floor dungeon. Visreal’s original practice scene remains available.

## Floors and boss rewards

- Each floor has a boss. The current layout puts the guardian in the fifth room.
- Bosses drop one equipment piece per floor. The first five floors provide the five pieces needed to complete the hero's equipment before floor six.
- Davey chose random reward order with no duplicates: the first five bosses each drop a different equipment slot, completing all five slots before floor six.
- Implemented in the combat prototype: shuffle the five reward slots once when a run starts and consume one entry for each of the first five guardian rewards. A new run gets a fresh shuffle. The dungeon uses the same shuffle for guardians on floors one to five.
- Visreal's paired swords count as a single equipment reward for his paired-swords slot.
- Floor six is the final floor, themed around something the selected class fears or dislikes. Davey selected a rogue's fear of being exposed for Visreal.
- Visreal faces moving searchlights and The Witness in the Unblinking Court. Clearing the last sanctum wins the run. Han’s and Ghalrym’s final floors remain open.
- Starting equipment, reward collection/equipping behavior, and item names remain open. All five of Visreal's equipment effects are approved below; Han's and Ghalrym's equipment effects remain open. These decisions do not remove the characters' approved visual outfits or weapons.

## Chosen gameplay controls

- Movement: W up, A left, S down, D right.
- Aim and melee attack: arrow keys in the corresponding direction.
- Movement and attack direction are independent, allowing movement one way while attacking another.
- This replaces the earlier assistant suggestion of mouse aiming and left-click attacks.
- Holding an arrow key repeatedly performs the basic melee attack in that direction. Davey selected hold-to-repeat for ease of play; individual key presses are not required for successive attacks.
- WASD and hold-to-repeat arrow attacks are implemented. The prototype adds diagonal aiming, Q for Shadowstep, and E for Venom Blades as provisional controls. Repeat cadence uses a temporary attack interval.
- Visreal's basic attack is a close-range sword slash. Player attacks are melee-only; no ranged player attacks. This does not decide enemy attack types, which remain open.
- Melee-only does not yet prescribe equal reach, damage, or attack speed. Those values remain open; Visreal's approved abilities are recorded below, and Han's and Ghalrym's kits remain to be designed with Davey.

## Progression and death

- Enemy kills grant XP during the run.
- Leveling increases stats for the rest of that run.
- No outside meta-progression in the initial version.
- Equipment earned during a run does not carry into a new run.
- Death leads to a game-over screen with options to return to the main menu or restart from floor one.
- For playtesting, levels increase maximum health and melee damage. Values and the XP curve are temporary.

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

Item names remain working proposals in [Visreal's character brief](characters/VISREAL.md#equipment). Equipment comes from the floor bosses in random order without duplicates as described above. The combat prototype implements these effects and skills with provisional bindings, poison behavior and equipment interactions documented in the [prototype guide](COMBAT-PROTOTYPE.md). Davey explicitly authorized temporary numbers; damage values, cooldowns, durations, and percentages will be tuned during playtesting.

### Ghalrym

A Druid who chooses feline form over all other forms and rests in it. He loves AI and anime cat girls, and would do anything to help his friends and save all the cat girls in the world. Davey refined the visual direction to a catgirl druid form and requested a human face. V4 is the sprite-production reference; see [Ghalrym's visual concepts](characters/GHALRYM.md). Skills are not yet defined.

### Han

A Druid who chooses bear form and enjoys being a caked-up bear. Davey approved the gnome-styled v3 concept. See [Han's approved visual reference](characters/HAN.md). Skills are not yet defined.

## Design sequence

1. Visreal's appearance and initial Godot sprite pack are approved.
2. Han's gnome-styled bear concept v3 is approved, and its first Godot sprite pack is built.
3. Ghalrym's human-faced catgirl v4 is the production reference, and its first Godot sprite pack is built.
4. Visreal's shadow-and-poison starter kit, five equipment slots, and all five equipment effects are approved. Numerical balance is deferred; Han's and Ghalrym's skill kits and equipment remain open.
5. Six floors and boss equipment drops in random order without duplicates are approved, with five pieces earned before the class-themed final floor. Davey chose exposure as Visreal's fear.
6. Refine each character's gameplay after appearance and skills are settled.

## Decisions still open

- Final target platforms and distribution method. A Windows x64 build is available for prototype testing.
- Final skill bindings; diagonal aim and Q/E are provisional prototype defaults, while movement, arrow attacks, and hold-to-repeat were selected by Davey.
- Han's and Ghalrym's skills; final cooldowns, resources, and numerical stats; review of Visreal's provisional poison interactions after playtesting.
- Equipment slots and effects for Han and Ghalrym; item names, starting gear, collection/equipping behavior, and any character-specific restrictions. Boss drops, random reward order without duplicates, and Visreal's five slots and effects are decided above.
- Enemy and boss types, behavior, and difficulty scaling.
- Playtest the six connected-room layouts, stairs and victory screen.
- Floor-six encounters for the two Druids.
- Specific art treatment, animation requirements, audio, and UI details.

Earlier assistant suggestions such as shadow rescue, healing purrs, an AI companion, and cheek quake are unapproved ideas, not requirements.

## Working within the rules

Davey supplies the creative direction. AI can make routine implementation decisions within agreed scope. Major unresolved design decisions and scope expansion go back to Davey. Overnight tasks must be human-defined and approved.

Completed work: repository setup, character concepts, Godot-ready sprite packs and a shared animation preview for all three characters, plus the playable Visreal combat prototype and Windows package. Davey explicitly requested the prototype using the agreed movement, attacks, skills, equipment, and temporary numbers. The test chamber, placeholder melee enemies, damage feedback, HUD, reward flow, pause/restart and automated checks support that request.

The playable dungeon uses six fixed routes, one safe refuge per floor, stairs after each of the first five sanctums, and victory in the sixth. Gates reopen after combat and cleared rooms stay empty. Each new refuge restores health and cooldowns. XP, levels and equipped rewards persist until a new run. Room routes, guardian names, searchlight timing, healing and stat values are working choices for playtesting.
