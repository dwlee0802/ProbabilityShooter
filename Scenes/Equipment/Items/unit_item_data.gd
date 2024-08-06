extends ItemData
class_name UnitItemData

## class of items that only have simple linear stat changes

@export_category("Stat Bonuses per Level")
@export
var movement: float = 0

func on_enter(unit: PlayerUnit, level: int):
	unit.movement_speed_bonus += movement * level
	if movement > 0:
		prints("Increased", str(unit.name), "'s movement speed by ", movement * level)

func on_exit(unit: PlayerUnit, level: int):
	unit.movement_speed_bonus -= movement * level
	if movement > 0:
		prints("Undo increasing", str(unit.name), "'s movement speed by ", movement * level)
