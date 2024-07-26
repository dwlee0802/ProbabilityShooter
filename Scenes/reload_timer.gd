extends Timer

signal reload_finished()

func _ready():
	timeout.connect(on_timeout)
	
func on_timeout():
	print("reload complete")
	reload_finished.emit()
