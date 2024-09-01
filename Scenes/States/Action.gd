extends RefCounted
class_name Action
## Class to hold user input info

enum Type {Attack, Move}

var type: Type

var mouse_position: Vector2

func _init(_type: Type, mouse_pos: Vector2):
	type = _type
	mouse_position = mouse_pos
