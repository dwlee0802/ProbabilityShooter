extends Camera2D
class_name CameraControl

@export
var zoom_speed: float = 10.0
var zoom_target: Vector2

@export
var move_speed: float = 10.0
var move_target: Vector2
# true when centering onto a unit
# becomes false when camera is panned
var moving: bool = false

## camera panning related stuff
var dragging: bool = false
var mouse_pos_init: Vector2
var camera_pos_init: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	zoom_target = zoom

func _process(delta):
	_zoom_camera(delta)
	_pan_camera()
	_center_camera(delta)
	
func _zoom_camera(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom_target *= 1.1
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom_target *= 0.9
		
	zoom = zoom.slerp(zoom_target, zoom_speed * delta)

func _pan_camera():
	if !dragging and Input.is_action_just_pressed("camera_pan"):
		moving = false
		mouse_pos_init = get_viewport().get_mouse_position()
		camera_pos_init = position
		dragging = true
		
	if dragging and Input.is_action_just_released("camera_pan"):
		dragging = false
		
	if dragging:
		var offset_vector: Vector2 = get_viewport().get_mouse_position() - mouse_pos_init
		position = camera_pos_init - offset_vector * 1 / zoom.x

func _center_camera(delta) -> void:
	if moving:
		position = position.lerp(move_target, move_speed * delta)
	
func center_camera_on(target_pos: Vector2) -> void:
	moving = true
	move_target = target_pos
