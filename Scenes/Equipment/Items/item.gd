extends Node
class_name Item

var data: ItemData

var level: int = 1

func on_enter(_unit: PlayerUnit):
	pass
	
func active(_unit):
	pass
	
func on_exit(_unit):
	pass

func _init(_data: ItemData):
	data = _data
