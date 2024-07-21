extends Node2D

@onready
var info_label: Label = $InfoLabel
@onready
var image: RadialProgress = $RadialProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	
	# depending on attack available, change infolabel content
	if InputManager.selected_unit != null:
		if InputManager.selected_unit.action_one_available:
			# show damage range
			image.progress = 100
			info_label.text = str(InputManager.selected_unit.damage_range.x) + "-" + str(InputManager.selected_unit.damage_range.y)
		else:
			var timer: Timer = InputManager.selected_unit.action_one_reload_timer
			#info_label.text = str(int(InputManager.selected_unit.action_one_reload_timer.time_left * 10)/10.0)
			image.progress = int((timer.wait_time - timer.time_left) * 100)
