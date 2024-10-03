extends Node
class_name ScalableTimer

var one_shot: bool = true

var stopped: bool = true

var wait_time: float = 0
	
var max_time: float = 0

var time_left: float:
	get():
		return max_time - wait_time

var progress: float:
	get():
		return wait_time
		
var speed: float = 1.0

signal timeout


func start(time: float = 0, scale: float = 1) -> void:
	wait_time = 0
	max_time = time
	speed = scale
	stopped = false

func _process(delta: float) -> void:
	if !stopped:
		if wait_time >= max_time:
			timeout.emit()
			wait_time = 0
			stopped = true
			if !one_shot:
				start(max_time)
		else:
			wait_time += delta * speed

func is_stopped() -> bool:
	return stopped

func stop() -> void:
	wait_time = 0
	speed = 0
	stopped = true
