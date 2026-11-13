# Visreal

## Human-defined character

- Class: Rogue.
- Race: undead blood elf.
- Height: 6 feet.
- Weight: 200 pounds.
- Facial hair: full beard.
- Hairstyle: long hair tied in a ponytail.
- Equipment: black and crimson leather gear.
- Additions requested by Davey: a cape and a lower-face mask inspired by WoW's Red Defias mask, with an original twist. After seeing v2, Davey requested a slightly longer cape.
- Weapons: dual-wielded swords, one in each hand.
- Personality: gamer, with a darker side; inclined to sneak away and sacrifice his own safety to protect his friends.

## Visual development

Keep the pointed elf ears, ponytail, leather armor, and two swords easy to read. The first concept shows the full beard; later concepts cover the nose and mouth with the requested mask, retaining the beard underneath. Keep eyes and hair visible.

Davey approved the v3 appearance with "Much better" and requested game-ready sprite sheets. V3 is now the visual reference for the first asset pack, including the dark hair, ash-gray skin, pale eyes, mask, and longer cape shown in it.

Use the game's agreed dark fantasy, World of Warcraft-inspired 2D parody direction. Concept art is a design reference, not an animation-ready sprite.

## Approved concept: v3

![Visreal concept v3: longer cape and crimson mask](../../assets/concepts/visreal-v3.png)

The revised design adds a black cape with crimson lining and a crimson cloth mask with black binding and asymmetrical X stitches. Version 3 extends the cape slightly beyond v2's length at Davey's request.

Generated using the built-in OpenAI image-generation tool. [V3 edit prompt](VISREAL-CONCEPT-V3-PROMPT.txt).

## Earlier concepts

- [V2: cape and mask](../../assets/concepts/visreal-v2.png) - [edit prompt](VISREAL-CONCEPT-V2-PROMPT.txt).
- V1: original unmasked appearance, below.

![Visreal concept v1](../../assets/concepts/visreal-v1.png)

Generated using the built-in OpenAI image-generation tool. [Exact generation prompt](VISREAL-CONCEPT-PROMPT.txt).

The original unmasked concept remains available as a face reference; v3 supersedes it for equipment and silhouette.

## Game asset pack

Davey selected Godot and explicitly requested complete sprite sheets ready to import. [Visreal asset pack and import instructions](../../assets/characters/visreal/README.md).

The first pack contains idle, walk, basic dual-sword attack, hurt, and death in four cardinal directions. Davey reviewed the preview and said "it looks good." These support the agreed movement, weapons, and death behavior. The approved signature skills below are not implemented or represented by dedicated effect assets yet. Four frames per animation and initial playback rates are implementation defaults, not approved combat timing or balance.

## Skills

Davey confirmed the basic attack: close-range sword slashes directed with the arrow keys, with hold-to-repeat. All playable heroes are melee-only. Davey chose shadow- and poison-powered melee for Visreal's combat identity.

Davey approved the complete starter kit below with "I like that kit for Visreal. Lets lock those in." These are agreed design decisions; gameplay is not implemented yet. The approved appearance remains the visual reference.

### Approved starter kit

The kit consists of one basic attack, two active skills, and one passive.

| Slot | Name | Approved effect |
| --- | --- | --- |
| Basic attack | Twin Slashes | Repeating close-range dual-sword slashes using the agreed arrow-key controls. |
| Active skill | Shadowstep | A short dash in the aim direction that empowers the next sword slash with shadow damage. |
| Active skill | Venom Blades | Temporarily coats the swords so melee hits poison enemies, dealing damage over time. |
| Passive | Nightshade | Shadow-empowered strikes deal extra damage to poisoned enemies. |

The intended combo is Venom Blades, melee hits to poison the enemy, then Shadowstep and a shadow-empowered slash benefiting from Nightshade. No skill keys, costs, cooldowns, durations, poison stacking rules, or damage values are selected yet.

## Equipment

### Approved slots

Davey chose five equipment slots for Visreal: **paired swords, armor, cape, mask, and trinket**. The paired swords occupy one slot as a set. This replaces the earlier three-slot suggestion. Equipment rules for Han and Ghalrym are not decided by this choice.

The swords, black-and-crimson leather armor, long cape, and crimson lower-face mask already have approved visual designs. Item names, gameplay bonuses, acquisition, replacement, and rarity remain undecided.

### Proposed starting equipment for discussion

These names and effects are proposals, not approved features. Numerical values are deferred with the game's stats. The proposed bonuses support Visreal's innate skills rather than being required to unlock them.

| Slot | Proposed item | Proposed effect |
| --- | --- | --- |
| Paired swords | Duskfang & Venomfang | Increase melee hit damage. |
| Armor | Crimsonhide Leathers | Reduce incoming damage. |
| Cape | Longcloak of the Veil | Reduce Shadowstep's cooldown. |
| Mask | Nightshade Wrap | Increase the damage dealt by poison. |
| Trinket | Umbral Seal | Increase the shadow bonus damage on the slash empowered by Shadowstep. |

These item names use the existing approved sword, armor, cape, and mask appearances. The trinket has no selected visual design. Whether this is a fixed starting loadout or equipment that can be replaced during a run remains to be chosen.
