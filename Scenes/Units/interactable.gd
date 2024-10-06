extends Node2D
class_name Interactable

@export_multiline
var interaction_label_text: String = ""

# called every frame by the interactor
# returns false if process is finished
func active(_dela: float, _user) -> bool:
	return false
	
func on_activate():
	pass
	
func on_exit():
	pass
