extends EquipmentItemData
class_name WeaponItemData

## class of items that only have simple linear stat changes to weapons

@export_category("Stat Bonuses per Level")
@export
var damage_range: Vector2i = Vector2i.ZERO

func on_enter(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_damage(damage_range * level)

func on_exit(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_damage(-damage_range * level)
