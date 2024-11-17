extends Node
class_name Buff
## Buffs are temporary stat changes

var unit
var buff_data: BuffData
var timer: Timer

# flag to mark this for freeing
var expired: bool = false

signal finished


func _init(_unit, _data) -> void:
	unit = _unit
	buff_data = _data
	
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(exit)
	add_child(timer)
	
func enter() -> void:
	unit.modulate = buff_data.change_color
	timer.start(buff_data.duration)
	print("buff applied")

func add_duration(time: float) -> void:
	var remaining: float = timer.time_left
	timer.stop()
	timer.start(remaining + time)
	expired = false
	
func exit() -> void:
	unit.modulate = Color.WHITE
	expired = true
	print("buff removed")
	finished.emit()
