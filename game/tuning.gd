extends RefCounted
## Temporary prototype values. Keep balance changes here, not in scene code.

const MAX_HEALTH := 140.0
const MOVE_SPEED := 230.0
const BODY_RADIUS := 16.0
const ATTACK_INTERVAL := 0.42
const ATTACK_WINDUP := 0.10
const ATTACK_REACH := 84.0
const ATTACK_HALF_ANGLE := 0.95
const PHYSICAL_DAMAGE := 18.0
const SHADOWSTEP_DAMAGE := 26.0
const SHADOWSTEP_COOLDOWN := 4.5
const DASH_SPEED := 760.0
const DASH_DURATION := 0.18
const EMPOWER_DURATION := 4.0
const VENOM_COOLDOWN := 8.0
const VENOM_DURATION := 4.0
const POISON_DURATION := 3.0
const POISON_TICK_INTERVAL := 0.5
const POISON_TICK_DAMAGE := 5.0
const NIGHTSHADE_MULTIPLIER := 1.5
const HURT_GRACE := 0.65

const WEAPON_SHADOW := 7.0
const WEAPON_POISON := 7.0
const ARMOR_REDUCTION := 0.25
const CAPE_COOLDOWN_MULTIPLIER := 0.7
const MASK_POISON_MULTIPLIER := 1.5
const TRINKET_SHADOW_MULTIPLIER := 1.5

const ENEMY_HEALTH := 64.0
const ENEMY_SPEED := 85.0
const ENEMY_DAMAGE := 12.0
const ENEMY_WINDUP := 0.65
const ENEMY_COOLDOWN := 1.15
const ENEMY_REACH := 56.0
const GUARDIAN_HEALTH := 230.0
const GUARDIAN_DAMAGE := 22.0

const SLOTS: Array[String] = ["swords", "armor", "cape", "mask", "trinket"]
const ITEM_NAMES := {
	"swords": "Duskfang & Venomfang", "armor": "Crimsonhide Leathers",
	"cape": "Longcloak of the Veil", "mask": "Nightshade Wrap", "trinket": "Umbral Seal"
}
const ITEM_EFFECTS := {
	"swords": "Shadow + poison on melee hits", "armor": "Less incoming damage",
	"cape": "Faster Shadowstep recharge", "mask": "Stronger poison damage",
	"trinket": "Stronger empowered shadow strike"
}

static func poison_multiplier(gear: Array[String]) -> float:
	return MASK_POISON_MULTIPLIER if "mask" in gear else 1.0

static func shadowstep_cooldown(gear: Array[String]) -> float:
	return SHADOWSTEP_COOLDOWN * (CAPE_COOLDOWN_MULTIPLIER if "cape" in gear else 1.0)

static func incoming_damage(amount: float, gear: Array[String]) -> float:
	return amount * (1.0 - ARMOR_REDUCTION if "armor" in gear else 1.0)

static func hit(gear: Array[String], empowered: bool, coated: bool, target_poisoned: bool) -> Dictionary:
	# Prototype choice: equipment poison is direct damage; Venom Blades applies the DoT.
	# Nightshade checks the target's existing poison status, before this hit applies one.
	var shadow := WEAPON_SHADOW if "swords" in gear else 0.0
	var empowerment := 0.0
	if empowered:
		empowerment = SHADOWSTEP_DAMAGE * (TRINKET_SHADOW_MULTIPLIER if "trinket" in gear else 1.0)
	shadow += empowerment
	var nightshade := empowered and target_poisoned
	if nightshade:
		shadow *= NIGHTSHADE_MULTIPLIER
	return {
		"physical": PHYSICAL_DAMAGE, "shadow": shadow,
		"poison": WEAPON_POISON * poison_multiplier(gear) if "swords" in gear else 0.0,
		"dot": POISON_TICK_DAMAGE * poison_multiplier(gear) if coated else 0.0,
		"nightshade": nightshade
	}
