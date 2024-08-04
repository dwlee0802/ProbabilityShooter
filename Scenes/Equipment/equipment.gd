extends Resource
class_name Equipment

@export
var ready: bool = true
var data: EquipmentData
@export_multiline
var description: String = "null"

var items = []

func on_activation(_unit: Unit, _direction: Vector2):
	pass

func _init(_data: EquipmentData):
	data = _data
