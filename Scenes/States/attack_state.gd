extends State

var mouse_position: Vector2

@export
var wait_time: float = 1

@export
var idle_state: State
@export
var move_state: State
@export
var unconscious_state: State

@onready
var timer: Timer = $Timer


func enter() -> void:
	super()
	parent.state_label.text = "Action1"
	mouse_position = parent.get_local_mouse_position()
	timer.start(parent.get_current_equipment().aim_time)
	if !parent.equipment_changed.is_connected(timer.stop):
		parent.equipment_changed.connect(timer.stop)
	if !timer.timeout.is_connected(on_aim_finished):
		timer.timeout.connect(on_aim_finished)
	
	parent.aim_line.default_color = parent.disabled_color
	parent.attack_line.visible = true
	parent.attack_line.set_point_position(1, parent.get_local_mouse_position().normalized() * 10000)
	parent.attack_line_anim.speed_scale = 1/parent.get_current_equipment().aim_time
	parent.attack_line_anim.play("RESET")
	parent.attack_line_anim.play("aim_animation")

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
	
	if parent.is_unconscious():
		return unconscious_state
		
	return null
	
func process_physics(_delta: float) -> State:
	return null

func on_aim_finished():
	parent.get_current_equipment().on_activation(parent, mouse_position)
	if !parent.get_current_equipment().have_bullets():
		parent.get_current_equipment().ready = false
	return idle_state
