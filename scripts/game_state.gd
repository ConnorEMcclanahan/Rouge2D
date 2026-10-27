extends Node
# global run state (autoload, access it as GameState anywhere)

var chest_opened: bool = false
var bones_defeated: bool = false

# run stats, reset on retry / new game
var max_health: int = 3
var speed_mult: float = 1.0
var attack_damage: int = 1
var attack_cooldown: float = 0.4
var knockback_mult: float = 1.0
var iframe_mult: float = 1.0
var chest_used: bool = false

# Run stats + settings
var kills: int = 0
var run_elapsed: float = 0.0
var sfx_volume: float = 80.0
var music_volume: float = 60.0

# set when you pick hearty, the player's refresh_from_gamestate uses it
var pending_heal: bool = false

func reset_run() -> void:
	max_health = 3
	speed_mult = 1.0
	attack_damage = 1
	attack_cooldown = 0.4
	knockback_mult = 1.0
	iframe_mult = 1.0
	chest_used = false
	chest_opened = false
	bones_defeated = false
	pending_heal = false
	kills = 0
	run_elapsed = 0.0

func apply_upgrade(id: String) -> void:
	match id:
		"hearty":
			max_health += 1
			pending_heal = true
		"swift":
			speed_mult += 0.25
		"sharp":
			attack_damage += 1
		"quick":
			attack_cooldown *= 0.5
		"heavy":
			knockback_mult += 0.5
		"sturdy":
			iframe_mult += 0.5

