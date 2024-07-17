extends Node
class_name State

## Hold a reference to the parent so that it can be controlled by the state
var parent: PlayerUnit

var animation_name: String

enum Action {None, One, Two}


func enter() -> void:
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
