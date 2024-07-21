extends Node
class_name InputManager

var game

static var camera: CameraControl

static var selected_unit: PlayerUnit = null

var slice_angle_size: float = PI/2


func _ready():
	InputManager.camera = $Camera2D
	
func _physics_process(_delta):
	var unit_index: int = 0
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
			_select_unit(selected_now)
	
	# distance function to find our next unit
	var in_slice = func(origin: Vector2, target: Vector2, _range: Vector2) -> bool:
		var angle: float = origin.angle_to_point(target)
		if angle < 0:
			angle += TAU
		return (_range.x <= angle) and (_range.y >= angle)
		
	var spacial_selection: bool = false
	var slice_range: Vector2 = Vector2(TAU - slice_angle_size/2, slice_angle_size/2)
	
	if Input.is_action_just_pressed("select_right"):
		spacial_selection = true
		in_slice = func(origin: Vector2, target: Vector2, _range: Vector2) -> bool:
			var angle: float = origin.angle_to_point(target)
			angle += TAU
			return (TAU - slice_angle_size/2) <= angle and (TAU + slice_angle_size/2) >= angle
	if Input.is_action_just_pressed("select_down"):
		spacial_selection = true
		slice_range = Vector2(PI/2 - slice_angle_size / 2, PI/2 + slice_angle_size / 2)
	if Input.is_action_just_pressed("select_left"):
		spacial_selection = true
		slice_range = Vector2(PI - slice_angle_size / 2, PI + slice_angle_size / 2)
	if Input.is_action_just_pressed("select_up"):
		spacial_selection = true
		slice_range = Vector2(3*PI/2 - slice_angle_size / 2, 3*PI/2 + slice_angle_size / 2)
	
	# find unit that is closest within slice
	if spacial_selection:
		# find unit closest among units that are inside slice
		if InputManager.selected_unit:
			var min_value: float = INF
			var new_selected: PlayerUnit
			for unit: PlayerUnit in game.units:
				var new_dist: float = InputManager.selected_unit.position.distance_to(unit.position)
				if InputManager.selected_unit != unit:
					if in_slice.call(InputManager.selected_unit.position, unit.position, slice_range) and min_value > new_dist:
						min_value = new_dist
						new_selected = unit
			
			if new_selected != null:
				_select_unit(new_selected)
	
	if Input.is_action_pressed("center_camera"):
		if InputManager.selected_unit:
			camera.center_camera_on(InputManager.selected_unit.position)

static func IsSelected(unit: PlayerUnit) -> bool:
	return selected_unit == unit

func _select_unit(unit: PlayerUnit) -> void:
	if InputManager.selected_unit != null:
		InputManager.selected_unit.deselected.emit()
		
	InputManager.selected_unit = unit
	
	if unit != null:
		unit.was_selected.emit()
