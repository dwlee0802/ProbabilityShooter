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

@export_category("Bullet Generation Modifiers")
@export
var anti_armor_chance: float = 0
@export
var piercing_chance: float = 0
@export
var explosive_chance: float = 0
@export
var buckshot_chance: float = 0
@export
var quickshot_chance: float = 0
@export
var fire_chance: float = 0


func on_enter(unit: PlayerUnit, level: int):
	super.on_enter(unit, level)
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_projectile_speed(projectile_speed * level)
		equipment.add_bonus_spread(spread * level)
		equipment.add_bonus_projectile_count(projectile_count * level)
		equipment.add_bonus_magazine_size(magazine_size * level)
		equipment.add_penetration_bonus(penetration_chance * level)
		
	# change bullet generation chance
	unit.bullet_generator_component.add_piercing_chance_bonus(piercing_chance)
	unit.bullet_generator_component.add_explosive_chance_bonus(explosive_chance)
	unit.bullet_generator_component.add_buckshot_chance_bonus(buckshot_chance)
	unit.bullet_generator_component.add_quickshot_chance_bonus(quickshot_chance)
	unit.bullet_generator_component.add_fire_chance_bonus(fire_chance)
		
func on_exit(unit: PlayerUnit, level: int):
	super.on_exit(unit, level)
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_projectile_speed(-projectile_speed * level)
		equipment.add_bonus_spread(-spread * level)
		equipment.add_bonus_projectile_count(-projectile_count * level)
		equipment.add_bonus_magazine_size(-magazine_size * level)
		equipment.add_penetration_bonus(-penetration_chance * level)
		
	# change bullet generation chance
	unit.bullet_generator_component.add_piercing_chance_bonus(-piercing_chance)
	unit.bullet_generator_component.add_explosive_chance_bonus(-explosive_chance)
	unit.bullet_generator_component.add_buckshot_chance_bonus(-buckshot_chance)
	unit.bullet_generator_component.add_quickshot_chance_bonus(-quickshot_chance)
	unit.bullet_generator_component.add_fire_chance_bonus(-fire_chance)
