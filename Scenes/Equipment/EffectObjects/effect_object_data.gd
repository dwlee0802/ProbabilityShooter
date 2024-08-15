extends Resource
class_name EffectObjectData

@export_category("Stat Changes")
@export
var speed: float = 0
@export
var aim_speed_modifier: float = 0

func effect(_unit: PlayerUnit) -> void:
	print("change something about unit")
	_unit.movement_speed_bonus += speed
	print(_unit.get_aim_time())
	_unit.add_aim_speed_modifier(aim_speed_modifier)
	print(_unit.get_aim_time())

## called when duration is over and is about to free self
func on_exit(_unit) -> void:
	print("undo effect stuff")
	_unit.movement_speed_bonus -= speed
	_unit.add_aim_speed_modifier(-aim_speed_modifier)
