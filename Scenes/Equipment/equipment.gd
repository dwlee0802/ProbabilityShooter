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

static var max_reload_time: float = 60

func on_activation(_unit: Unit, _direction: Vector2):
	pass

func _init(_data: EquipmentData):
	data = _data

func add_reload_speed_modifier(amount: float) -> void:
	reload_speed_modifier += amount
	if amount != 0:
		print("Changed reload speed modifier by " + str(amount))
	
func get_reload_time() -> float:
	if 1 + reload_speed_modifier <= 0:
		return Equipment.max_reload_time
		
	return data.reload_time / (1 + reload_speed_modifier)
