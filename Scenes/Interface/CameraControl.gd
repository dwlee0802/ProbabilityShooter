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

var noise = FastNoiseLite.new()
var noise_i: float = 0.0

var SHAKE_DECAY_RATE: float = 2.0
var NOISE_SHAKE_SPEED: float = 30.0
var NOISE_SHAKE_STRENGTH: float = 60.0
var shake_strength: float = 0

static var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	zoom_target = zoom
	
	noise.frequency = 2
	noise.fractal_octaves = 3
	
	CameraControl.camera = self

func _process(delta):
	_zoom_camera(delta)
	_pan_camera()
	_center_camera(delta)
	
	#shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	shake_strength -= delta * (SHAKE_DECAY_RATE)
	if shake_strength < 2:
		shake_strength = 0
		
	offset = get_noise_offset(delta)
	
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

# sets the size of unit shortcut labels
func scale_unit_shortcut_label(units):
	for unit: PlayerUnit in units:
		var label: Label = unit.shortcut_label
		label.scale = Vector2(1 / zoom.x, 1/zoom.y)

func scale_health_label(units):
	for unit: EnemyUnit in units:
		var label: Label = unit.health_label
		label.scale = Vector2(1 / zoom.x, 1/zoom.y)
		
func shake_screen(intensity, duration):
	noise_i = 0
	shake_strength = intensity / zoom.x
	SHAKE_DECAY_RATE = duration / zoom.x

func get_noise_offset(delta: float):
	noise_i += delta * NOISE_SHAKE_SPEED
	var output: Vector2 = Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)
	return output
