extends ItemData
class_name EquipmentItemData

## class that change equipment data

@export_category("Stat Bonuses per Level")
## How much faster unit reloads faster. 1 means reloading is twice as fast
@export
var reload_speed_modifier: float = 0
@export
var aim_speed_modifier: float = 0

func on_enter(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	equipment.add_reload_speed_modifier(reload_speed_modifier * level)

func on_exit(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	equipment.add_reload_speed_modifier(-reload_speed_modifier * level)
