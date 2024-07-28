extends State

var attack_direction_queue = []

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
	save_mouse_position()
	timer.start(parent.get_current_equipment().data.aim_time)
	if !parent.equipment_changed.is_connected(timer.stop):
		parent.equipment_changed.connect(timer.stop)
	if !timer.timeout.is_connected(on_aim_finished):
		timer.timeout.connect(on_aim_finished)
	
	parent.aim_line.default_color = parent.disabled_color
	parent.attack_line.visible = true
	parent.attack_line.set_point_position(1, parent.get_local_mouse_position().normalized() * 10000)
	parent.attack_line_anim.speed_scale = 1/parent.get_current_equipment().data.aim_time
	parent.attack_line_anim.play("RESET")
	parent.attack_line_anim.play("aim_animation")

func exit() -> void:
	super()
	parent.attack_line.visible = false
	parent.attack_line_anim.stop()
	attack_direction_queue.clear()
	timer.stop()
	
func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		enter()
	if Input.is_action_just_pressed("queue_attack"):
		save_mouse_position()
	return null

func process_frame(_delta: float) -> State:
	parent.state_label.text = "Action1 in " + str(int(timer.time_left + 1))
	
	if parent.is_unconscious():
		return unconscious_state
	
	if attack_direction_queue.is_empty():
		return idle_state
		
	return null
	
func process_physics(_delta: float) -> State:
	return null

func on_aim_finished() -> void:
	if attack_direction_queue.size() == 0:
		push_error("Aim finished but no attack direction.")
	else:
		parent.get_current_equipment().on_activation(parent, attack_direction_queue.pop_front())
		
	if !parent.get_current_equipment().have_bullets():
		parent.get_current_equipment().ready = false

# save local mouse position vector to attack dir queue
func save_mouse_position() -> void:
	attack_direction_queue.push_back(parent.get_local_mouse_position())
