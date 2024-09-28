extends Resource
class_name ItemData

## base class for items that modify unit

@export
var item_name: String = "Null"
@export
var icon: Texture2D
var default_icon = preload("res://Art/32x32_white_square.png")
@export_multiline
var description: String = "null"
@export
var color: Color = Color.WHITE

@export
var disabled: bool = false


func on_enter(_unit: PlayerUnit, _level: int):
	return
	
func on_exit(_unit: PlayerUnit, _level: int):
	return

func active(_unit):
	return
	
func on_attack(_unit):
	return
	
func _to_string() -> String:
	return item_name
