extends ItemData
class_name WeaponBoostData

@export
var damage_max_increase: int = 0
@export
var damage_min_increase: int = 0

func on_enter(unit: PlayerUnit, level: int):
	var eq: Equipment = unit.get_current_equipment()
