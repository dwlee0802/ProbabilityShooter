extends Node
class_name UpgradesManager

## Dictionary to hold active upgrades <event code, upgrade>
static var upgrades = {}

static var game_ref

static func _static_init() -> void:
	add_upgrade(load("res://Data/Upgrade/explode_on_upgrade_taken.tres"))
	
static func process_event(event: Event):
	if !upgrades.has(event.code):
		return
		
	for upg: Upgrade in upgrades[event.code]:
		if event.code == Event.EventCode.UPGRADE_SELF_TAKEN:
			# if event code is upgrade self taken, only use effect if subject is same as upgrade
			if upg == event.object:
				upg.effect.activate(game_ref, event)
				print("meow????")
		else:
			upg.effect.activate(game_ref, event)

static func add_upgrade(upgrade: Upgrade):
	var code = upgrade.condition_event_code
	if !upgrades.has(code):
		upgrades[code] = []
	upgrades[code].append(upgrade)
	
	print(upgrade.upgrade_name + " was added.")

static func reset_upgrades():
	upgrades.clear()
