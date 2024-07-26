extends Node2D

@onready
var info_label: Label = $InfoLabel
@onready
var image: RadialProgress = $RadialProgress
@onready
var selected_unit_pointer: Node2D = $SelectedUnitPointer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	
	# depending on attack available, change infolabel content
	if InputManager.selected_unit != null:
		# show damage range
		image.progress = 100
		var current_eq: Equipment = InputManager.selected_unit.get_current_equipment()
		info_label.text = str(current_eq.damage_range.x) + "-" + str(current_eq.damage_range.y)
		if !InputManager.selected_unit.get_current_equipment().ready:
			var timer: Timer = InputManager.selected_unit.action_one_reload_timer
			#info_label.text = str(int(InputManager.selected_unit.action_one_reload_timer.time_left * 10)/10.0)
			image.progress = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
			if timer.is_stopped():
				image.progress = 0
		
		# rotate pointer
		var direction_to_cursor: Vector2 = InputManager.selected_unit.get_local_mouse_position()
		selected_unit_pointer.rotation = direction_to_cursor.angle()
