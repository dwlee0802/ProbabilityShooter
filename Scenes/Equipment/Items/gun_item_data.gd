extends WeaponItemData
class_name GunItemData

## class of items that only have simple linear stat changes to weapons

@export_category("Stat Bonuses per Level")
@export
var projectile_speed: float = 0

func on_enter(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_projectile_speed(projectile_speed * level)

func on_exit(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_projectile_speed(-projectile_speed * level)
