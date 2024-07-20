extends State

var mouse_position: Vector2

@export
var projectile_speed: float = 8000
@export
var wait_time: float = 1

@export
var idle_state: State
@export
var move_state: State

@onready
var timer: Timer = $Timer


func enter() -> void:
	super()
	parent.state_label.text = "Action1"
	mouse_position = parent.get_local_mouse_position()
	timer.start(parent.action_one_aim_time)
	parent.aim_line.default_color = parent.disabled_color
	parent.attack_line.visible = true
	parent.attack_line.set_point_position(1, parent.get_local_mouse_position().normalized() * 10000)
	parent.attack_line_anim.speed_scale = parent.action_one_aim_time
	parent.attack_line_anim.play("RESET")
	parent.attack_line_anim.play("aim_animation")
	
	print("attack state")

func exit() -> void:
	super()
	parent.attack_line.visible = false
	parent.attack_line_anim.stop()
	
func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		enter()
		 
	return null

func process_frame(_delta: float) -> State:
	parent.state_label.text = "Action1 in " + str(int(timer.time_left + 1))
	return null
	
func process_physics(_delta: float) -> State:
	if timer.is_stopped():
		parent.action_one_available = false
		
		var bullet: Projectile = parent.bullet_scene.instantiate()
		bullet.launch(mouse_position.normalized(), projectile_speed, randi_range(1, 201))
		bullet.global_position = parent.global_position
		
		get_tree().root.add_child(bullet)
		
		return idle_state
	
	return null
