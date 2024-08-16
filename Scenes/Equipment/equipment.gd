extends RefCounted
class_name Equipment

@export
var ready: bool = true
var data: EquipmentData
@export_multiline
var description: String = "null"


func on_activation(_unit: Unit, _direction: Vector2):
	if data.is_consumable:
		## equip main weapon
		_unit.set_current_equipment(0)
		## remove secondary
		_unit.remove_equipment(1)

func _init(_data: EquipmentData):
	data = _data
