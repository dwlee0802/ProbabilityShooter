extends Node
class_name EffectObject

var data: EffectObjectData = null
var duration_left: float = 0

signal timeout(data)

func _init(_data: EffectObjectData, duration: float):
	data = _data
	duration_left = duration
	
func _process(delta):
	duration_left -= delta
	if duration_left < 0:
		timeout.emit(self)
