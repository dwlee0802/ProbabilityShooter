extends Node
class_name UpgradesManager

## Dictionary to hold active upgrades <event code, upgrade>
static var upgrades = {}

static var game_ref

static func _static_init() -> void:
	add_upgrade(load("res://Data/Upgrade/explosive_corpse.tres"))
	
static func process_event(event: Event):
	if !upgrades.has(event.code):
		return
		
	for upg: Upgrade in upgrades[event.code]:
		upg.effect.activate(game_ref, event)

static func add_upgrade(upgrade: Upgrade):
	process_event(Event.new(upgrade, null, null, Event.EventCode.UPGRADE_TAKEN))
	
	var code = upgrade.condition_event_code
	if !upgrades.has(code):
		upgrades[code] = []
	upgrades[code].append(upgrade)

static func reset_upgrades():
	upgrades.clear()
