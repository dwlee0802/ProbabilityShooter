extends Node
class_name InputManager

var game

@onready
var camera: CameraControl = $Camera2D

static var selected_unit: PlayerUnit = null


func _physics_process(_delta):
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
	
	# distance function to find our next unit
	var dist_func = func() -> float:
		return 0
	var spacial_selection: bool = false
	
	if Input.is_action_just_pressed("select_right"):
		spacial_selection = true
		dist_func = func(origin: PlayerUnit, target: PlayerUnit):
			return target.position.x - origin.position.x
	if Input.is_action_just_pressed("select_left"):
		spacial_selection = true
		dist_func = func(origin: PlayerUnit, target: PlayerUnit):
			return origin.position.x - target.position.x
	if Input.is_action_just_pressed("select_up"):
		spacial_selection = true
		dist_func = func(origin: PlayerUnit, target: PlayerUnit):
			return origin.position.y - target.position.y
	if Input.is_action_just_pressed("select_down"):
		spacial_selection = true
		dist_func = func(origin: PlayerUnit, target: PlayerUnit):
			return target.position.y - origin.position.y
	
	if spacial_selection:
		# find unit closest in some direction
		if selected_unit:
			var min_value: float = INF
			var new_selected: PlayerUnit
			for unit: PlayerUnit in game.units:
				if selected_unit != unit:
					var new_dist = dist_func.call(selected_unit, unit)
					if new_dist >= 0 and min_value > new_dist:
						min_value = new_dist
						new_selected = unit
			
			if new_selected != null:
				selected_unit = new_selected
				camera.center_camera_on(new_selected.position)
			

static func IsSelected(unit: PlayerUnit) -> bool:
	return selected_unit == unit
