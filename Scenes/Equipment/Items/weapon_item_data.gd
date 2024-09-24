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
	super.on_enter(unit, level)
	unit.bullet_generator_component.add_bonus_damage(damage_range * level)

func on_exit(unit: PlayerUnit, level: int):
	super.on_exit(unit, level)
	unit.bullet_generator_component.add_bonus_damage(-damage_range * level)
