extends Node2D
class_name Interactable

# called every frame by the interactor
# returns false if process is finished
func active(_dela: float, _user: PlayerUnit) -> bool:
	return false
	
func on_activate():
	pass
	
func on_exit():
	pass