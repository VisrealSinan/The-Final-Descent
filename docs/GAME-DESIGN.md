# The Final Descent: agreed design

This file records decisions made by Davey. Suggestions are not approved features until Davey chooses them.

## Core

- Single-player, top-down 2D dungeon crawler with RPG elements.
- Players select one of three heroes; the chosen hero ventures alone.
- Direct movement and active class-based attacks or spells.
- Survive as many floors of the void as possible; no fixed final floor has been specified.
- Exactly five rooms per floor: an enemy-free spawn room plus four rooms containing enemies.
- Dark fantasy, World of Warcraft-inspired parody art direction.

## Progression and death

- Enemy kills grant XP during the run.
- Leveling increases stats for the rest of that run.
- No outside meta-progression in the initial version.
- Death leads to a game-over screen with options to return to the main menu or restart from floor one.
- Stat definitions, values, XP curves, and level-up details will be defined later.

## Characters

### Visreal

A gamer who is naturally a Rogue. He has a darker, self-sacrificing side and is prone to sneaking away to save his friends rather than himself. See [his appearance brief](characters/VISREAL.md).

### Ghalrym

A Druid who chooses cat form over all other forms and rests in it. He loves AI and anime cat girls, and would do anything to help his friends and save all the cat girls in the world. Appearance and skills are not yet defined.

### Han

A Druid who chooses bear form and enjoys being a caked-up bear. Appearance details and skills are not yet defined.

## Design sequence

1. Define Visreal's appearance, then his skills.
2. Define Ghalrym's appearance and skills.
3. Define Han's appearance and skills.
4. Refine each character's gameplay after appearance and skills are settled.

## Decisions still open

- Platform, engine, distribution method, and controls.
- Character skills, cooldowns, resources, and numerical stats.
- Enemy types, behavior, and difficulty scaling.
- Room connections, floor layouts, and the condition for descending.
- Specific art treatment, animation requirements, audio, and UI details.

Earlier assistant suggestions such as shadow rescue, healing purrs, an AI companion, and cheek quake are unapproved ideas, not requirements.

## Working within the rules

Davey supplies the creative direction. AI can make routine implementation decisions within agreed scope. Major unresolved design decisions and scope expansion go back to Davey. Overnight tasks must be human-defined and approved.

Current agreed work: repository setup, recording these decisions, and developing Visreal's appearance from Davey's description. This is not authorization to invent all remaining game systems.
