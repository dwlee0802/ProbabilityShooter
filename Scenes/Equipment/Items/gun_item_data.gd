extends WeaponItemData
class_name GunItemData

## class of items that only have simple linear stat changes to weapons

@export_category("Stat Bonuses per Level")
@export
var projectile_speed: float = 0
@export
var spread: float = 0
@export
var projectile_count: int = 0
@export
var magazine_size: int = 0
@export
var penetration_chance: float = 0


func on_enter(unit: PlayerUnit, level: int):
	super.on_enter(unit, level)
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_projectile_speed(projectile_speed * level)
		equipment.add_bonus_spread(spread * level)
		equipment.add_bonus_projectile_count(projectile_count * level)
		equipment.add_bonus_magazine_size(magazine_size * level)
		equipment.add_penetration_bonus(penetration_chance * level)

func on_exit(unit: PlayerUnit, level: int):
	super.on_exit(unit, level)
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_projectile_speed(-projectile_speed * level)
		equipment.add_bonus_spread(-spread * level)
		equipment.add_bonus_projectile_count(-projectile_count * level)
		equipment.add_bonus_magazine_size(-magazine_size * level)
		equipment.add_penetration_bonus(-penetration_chance * level)
