extends Interactable
class_name FabricationBench

var wait_time: float = 5
var time_holder: float = 0

# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, _user: PlayerUnit) -> bool:
	time_holder += _delta
	if time_holder >= wait_time:
		print("complete")
		return false
	return true
	
func on_activate():
	pass
	
func on_exit():
	pass
