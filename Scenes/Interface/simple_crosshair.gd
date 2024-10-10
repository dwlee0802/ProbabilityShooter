extends Node2D

var player_unit: PlayerUnit

var first_frame: bool = true

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	
