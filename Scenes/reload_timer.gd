extends Timer

@export
var action_number: int = -1

signal reload_finished(num)

func _ready():
	timeout.connect(on_timeout)
	
func on_timeout():
	if action_number <= 0:
		push_error("No action number set in reload timer")
		return
		
	reload_finished.emit(action_number)
