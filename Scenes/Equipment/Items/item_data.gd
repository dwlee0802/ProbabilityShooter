extends Resource
class_name ItemData

## base class for items that modify unit

@export
var item_name: String = "Null"
@export
var icon: Texture2D
@export_multiline
var description: String = "null"

func on_enter(_unit: PlayerUnit, _level: int):
	return
	
func on_exit(_unit: PlayerUnit, _level: int):
	return

func active(_unit):
	return
	
func on_attack(_unit):
	return
