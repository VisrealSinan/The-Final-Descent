extends RefCounted

const T = preload("res://game/tuning.gd")
const IDS: Array[String] = ["visreal", "han", "ghalrym"]
const DRUID_SLOTS: Array[String] = ["claws", "body", "back", "head", "neck"]
const DRUID_GEAR := {"claws": "Claw wraps", "body": "Hide armor", "back": "Mantle", "head": "Circlet", "neck": "Charm"}
const DRUID_GEAR_DAMAGE := 2.0
const VISUALS := {
	"visreal": preload("res://assets/characters/visreal/visreal_visual.tscn"),
	"han": preload("res://assets/characters/han/han_visual.tscn"),
	"ghalrym": preload("res://assets/characters/ghalrym/ghalrym_visual.tscn")
}
const ROLES := {"visreal": "Shadow & poison rogue", "han": "Bear druid", "ghalrym": "Catgirl druid"}
const ATTACKS := {"visreal": "Twin Slashes", "han": "Bear Swipe", "ghalrym": "Cat Claws"}
const SUMMARIES := {
	"visreal": "Twin swords and poison.\nDash through the shadows.",
	"han": "Heavy swipes in a wide arc.\nHigh starting health.",
	"ghalrym": "Quick claw strikes.\nSwift on the move."
}
const COLORS := {"visreal": Color("be7387"), "han": Color("c5a06a"), "ghalrym": Color("a99ad3")}

static func slots(id: String) -> Array[String]:
	return T.SLOTS if id == "visreal" else DRUID_SLOTS

static func item_name(id: String, slot: String) -> String:
	return T.ITEM_NAMES[slot] if id == "visreal" else DRUID_GEAR[slot]

static func item_effect(id: String, slot: String) -> String:
	return T.ITEM_EFFECTS[slot] if id == "visreal" else "+%d melee damage" % int(DRUID_GEAR_DAMAGE)
