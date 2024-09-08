extends Node
class_name WASDMovementComponent

@export
var max_speed: float = 10000
@export
var acceleration: float = 10000
@export
var deceleration: float = 10

## called every frame in physics process
## implements top down WASD movement
func physics_update(unit: RigidBody2D, delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO
	var current_vel: Vector2 = unit.linear_velocity
	# Pressed W
	if Input.is_action_pressed("select_up"):
		if current_vel.y < max_speed:
			input_dir += Vector2.UP
	# Pressed A
	if Input.is_action_pressed("select_left"):
		if current_vel.x > -max_speed:
			input_dir += Vector2.LEFT
	# Pressed S
	if Input.is_action_pressed("select_down"):
		if current_vel.y > -max_speed:
			input_dir += Vector2.DOWN
	# Pressed D
	if Input.is_action_pressed("select_right"):
		if current_vel.x < max_speed:
			input_dir += Vector2.RIGHT
	input_dir = input_dir.normalized()
	
	unit.apply_central_impulse(input_dir * acceleration * delta)
	
	#print(unit.linear_velocity)
