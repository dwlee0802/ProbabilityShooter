extends Resource
class_name Equipment

@export
var ready: bool = true
var data: EquipmentData
@export_multiline
var description: String = "null"

var items = {}

var reload_speed_modifier: float = 0
var aim_speed_modifier: float = 0

func on_activation(_unit: Unit, _direction: Vector2):
	pass

func _init(_data: EquipmentData):
	data = _data

func get_reload_time() -> float:
	print("reload modifier: " + str(reload_speed_modifier))
	print("reload time: " + str(data.reload_time / (1 + reload_speed_modifier)))
	return data.reload_time / (1 + reload_speed_modifier)
