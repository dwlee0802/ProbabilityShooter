extends Node2D
class_name Interactable

@export_multiline
var interaction_label_text: String = ""

# called every frame by the interactor
# returns false if process is finished
func active(_dela: float, _user: PlayerUnit) -> bool:
	return false

# one time interaction
func use(_user: PlayerUnit) -> void:
	pass
	
func on_activate():
	pass
	
func on_exit():
	pass
