extends RefCounted
class_name Upgrades
## Roguelike upgrade pool. Static so it can be used from anywhere via preload.

const UPGRADE_DEFS := {
	"hearty": {"name": "Hearty", "desc": "+1 Max Heart & Full Heal"},
	"swift": {"name": "Swift", "desc": "+25% Move Speed"},
	"sharp": {"name": "Sharp", "desc": "+1 Sword Damage"},
	"quick": {"name": "Quick", "desc": "Swing 2x Faster"},
	"heavy": {"name": "Heavy", "desc": "+50% Knockback"},
	"sturdy": {"name": "Sturdy", "desc": "+50% Invincibility Time"},
}

static func roll_three() -> Array[String]:
	var ids: Array[String] = []
	for id in UPGRADE_DEFS:
		ids.append(id)
	ids.shuffle()
	return ids.slice(0, 3)
