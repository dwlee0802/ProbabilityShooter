extends Node
class_name UpgradesManager

var player_unit: PlayerUnit

## Dictionary to hold active upgrades <event code, upgrade>
var upgrades = {}

func on_event(event: Event):
	if !upgrades.has(event.code):
		return
		
	for upg:Upgrade in upgrades[event.code]:
		upg.effect.activate(event)

func add_upgrade(upgrade: Upgrade):
	var code = upgrade.condition_event_code
	if !upgrades.has(code):
		upgrades[upgrade.code] = []
	upgrades[upgrade.code].append(upgrade)

func reset_upgrades():
	upgrades.clear()
