extends Resource
class_name Equipment

@export
var ready: bool = true
var data: EquipmentData
@export_multiline
var description: String = "null"

var items = {}

func on_activation(_unit: Unit, _direction: Vector2):
	pass

func _init(_data: EquipmentData):
	data = _data

func add_item(data: ItemData):
	if items.find_key(data):
		items[data].level += 1
	else:
		items[data] = Item.new(data)
		items[data].on_enter(self)
