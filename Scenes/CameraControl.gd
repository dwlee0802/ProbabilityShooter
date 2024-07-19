extends Camera2D
class_name CameraControl

@export
var zoomSpeed: float = 10.0
var zoomTarget: Vector2

## camera panning related stuff
var dragging: bool = false
var mouse_pos_init: Vector2
var camera_pos_init: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	zoomTarget = zoom

func _process(delta):
	zoom_camera(delta)
	pan_camera()
	
func zoom_camera(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *= 1.1
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
		
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)

func pan_camera():
	if !dragging and Input.is_action_just_pressed("camera_pan"):
		mouse_pos_init = get_viewport().get_mouse_position()
		camera_pos_init = position
		dragging = true
		
	if dragging and Input.is_action_just_released("camera_pan"):
		dragging = false
		
	if dragging:
		var offset_vector: Vector2 = get_viewport().get_mouse_position() - mouse_pos_init
		position = camera_pos_init - offset_vector * 1 / zoom.x

func center_camera(at_pos: Vector2) -> void:
	position = at_pos
