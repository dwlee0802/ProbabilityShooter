extends EquipmentItemData
class_name WeaponItemData

## class of items that only have simple linear stat changes to weapons

@export_category("Stat Bonuses per Level")
@export
var damage_range: Vector2i = Vector2i.ZERO
## percentile changes to the damage range
@export
var damage_modifier: float = 0

func on_enter(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_damage(damage_range * level)
		equipment.add_damage_multiplier(damage_modifier * level)

func on_exit(unit: PlayerUnit, level: int):
	var equipment: Equipment = unit.get_current_equipment()
	if equipment is Gun:
		equipment.add_bonus_damage(-damage_range * level)
		equipment.add_damage_multiplier(-damage_modifier * level)
