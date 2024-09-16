extends Node
class_name State

## Hold a reference to the parent so that it can be controlled by the state
var parent

var animation_name: String


func enter() -> void:
	#print("\n***Enter " + name + "***")
	return

func exit() -> void:
	#print("***Exit " + name + "***\n")
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
