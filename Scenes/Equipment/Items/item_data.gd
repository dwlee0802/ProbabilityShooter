extends Resource
class_name ItemData

@export
var item_name: String = "Null"
@export
var icon: Texture2D
@export_multiline
var description: String = "null"

func on_enter(_unit: PlayerUnit, _level: int):
	pass
	
func active(_unit):
	pass
	
func on_exit(_unit):
	pass

func on_attack(_unit):
	pass
