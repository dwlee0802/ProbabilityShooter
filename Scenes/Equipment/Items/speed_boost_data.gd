extends ItemData
class_name SpeedBoostItemData

@export
var speed_increase_per_level: int = 50

func on_enter(unit: PlayerUnit, level: int):
	unit.movement_speed_modifier += speed_increase_per_level * level
	print("Increased " + unit.name + " speed by " + str(speed_increase_per_level * level))
