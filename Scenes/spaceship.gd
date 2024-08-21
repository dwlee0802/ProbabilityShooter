extends RigidBody2D
class_name Spaceship

@export
var speed_max: float = 300
var speed: float = 0
var acceleration: float = 10

@export
var angular_max: float = 10
var angular_acceleration: float = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("forward"):
		speed += delta * acceleration
		if speed > speed_max:
			speed = speed_max
	linear_velocity = Vector2.from_angle(rotation) * speed
	
	if Input.is_action_pressed("rotate_right"):
		if angular_velocity < angular_max:
			apply_torque_impulse(angular_acceleration * delta)
	if Input.is_action_pressed("rotate_left"):
		if angular_velocity > -angular_max:
			apply_torque_impulse(-angular_acceleration * delta)
		
