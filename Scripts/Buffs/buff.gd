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
	timer.name = "buff timer"
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(exit)
	add_child(timer)
	
func enter() -> void:
	# apply changes to stats
	unit.modulate = buff_data.change_color
	if unit is PlayerUnit:
		unit.stat_component.add_aim_time_modifier(buff_data.aim_time_modifier_bonus)
		
	timer.start(buff_data.duration)

func add_duration(time: float) -> void:
	var remaining: float = timer.time_left
	timer.stop()
	timer.start(remaining + time)
	expired = false

func reset_duration() -> void:
	timer.stop()
	timer.start(buff_data.duration)
	expired = false
	
func exit() -> void:
	# undo changes to stats
	unit.modulate = Color.WHITE
	if unit is PlayerUnit:
		unit.stat_component.add_aim_time_modifier(-buff_data.aim_time_modifier_bonus)
		
	expired = true
	finished.emit()
