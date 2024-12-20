extends Node
class_name WASDMovementComponent

var max_speed: float = 10000
@export
var _base_speed: float = 10000
var min_speed: float = 8000

@export
var acceleration: float = 10000
@export
var deceleration: float = 10

var dash_timer: Timer = Timer.new()
var dash_modifier: float = 1
@export
var dash_strength: float = 10
@export
var dash_cooldown: float = 0.5

var run_modifier: float = 1
var run_strength: float = 2

signal dashed


func _ready() -> void:
	add_child(dash_timer)
	dash_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_timer.one_shot = true
	dash_timer.autostart = false

## called every frame in physics process
## implements top down WASD movement
## returns true if input is made by player
func physics_update(unit: RigidBody2D, delta: float) -> bool:
	dash_modifier = 1
	run_modifier = 1
	
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
		
	if Input.is_action_pressed("run"):
		run_modifier = run_strength
		
	unit.apply_central_impulse(input_dir * acceleration * dash_modifier * run_modifier * delta)
	
	#print(unit.linear_velocity.length())
	
	return input_dir != Vector2.ZERO

func input_update(unit: RigidBody2D) -> void:
	if Input.is_action_just_pressed("dash"):
		if dash_timer.is_stopped():
			# apply dash
			unit.apply_central_impulse(unit.linear_velocity.normalized() * dash_strength)
			dash_timer.start(dash_cooldown)
			dashed.emit()
		else:
			pass
			#print("Dash on cooldown")

func reset_stats() -> void:
	max_speed = _base_speed

func add_movement_speed(amount: float) -> void:
	acceleration += amount
	
	#print("Movement speed increased by " + str(int(amount)) + ". New speed: " + str(max_speed))
