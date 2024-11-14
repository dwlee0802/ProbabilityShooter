extends Node
class_name UpgradesManager

## Dictionary to hold active upgrades <event code, upgrade>
static var upgrades = {}

static var game_ref

static func _static_init() -> void:
	#add_upgrade(load("res://Data/Upgrade/missile_on_shoot.tres"))
	return
	
static func process_event(event: Event):
	if !upgrades.has(event.code):
		return
		
	if event.code == Event.EventCode.STATIC_UPGRADE_TAKEN:
		if event.object is Upgrade:
			event.object.effect.activate(game_ref, event)
	else:
		for upg: Upgrade in upgrades[event.code]:
			upg.effect.activate(game_ref, event)

static func add_upgrade(upgrade: Upgrade):
	var code = upgrade.condition_event_code
	if !upgrades.has(code):
		upgrades[code] = []
	upgrades[code].append(upgrade)
	
	print(upgrade.upgrade_name + " was added.")

static func reset_upgrades():
	upgrades.clear()
