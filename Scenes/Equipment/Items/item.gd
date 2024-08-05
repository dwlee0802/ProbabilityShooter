extends Node
class_name Item

var data: ItemData

var level: int = 1

func _init(_data: ItemData):
	data = _data

func on_enter(unit: PlayerUnit):
	data.on_enter(unit, level)
