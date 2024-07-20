extends Node
class_name InputManager

var game

@onready
var camera: CameraControl = $Camera2D

static var selected_unit: PlayerUnit = null


func _physics_process(delta):
	var unit_index: int = 0
	var center_camera: bool = Input.is_physical_key_pressed(KEY_SHIFT)
	if Input.is_action_just_pressed("select_unit_one"):
		unit_index = 1
	if Input.is_action_just_pressed("select_unit_two"):
		unit_index = 2
	if Input.is_action_just_pressed("select_unit_three"):
		unit_index = 3
	if Input.is_action_just_pressed("select_unit_four"):
		unit_index = 4
	
	if unit_index > 0 and unit_index <= game.units.size():
		var selected_now: PlayerUnit = game.units[unit_index - 1]
		if selected_now != null:
			selected_unit = selected_now
			if center_camera:
				camera.center_camera_on(selected_unit.position)
	

static func IsSelected(unit: PlayerUnit) -> bool:
	return selected_unit == unit
