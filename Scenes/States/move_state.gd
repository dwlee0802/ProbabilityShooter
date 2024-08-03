extends State

@export
var idle_state: State
@export
var action_one_state: State
@export
var unconscious_state: State

var destination: Vector2


func enter() -> void:
	super()
	parent.state_label.text = "Move"
	destination = parent.get_global_mouse_position()
	
	# cancel reload
	if !parent.action_one_reload_timer.is_stopped():
		parent.action_one_reload_timer.stop()

func exit() -> void:
	super()
	destination = parent.global_position
	
func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed("right_click"):
		destination = parent.get_global_mouse_position()
		if !parent.action_one_reload_timer.is_stopped():
			parent.action_one_reload_timer.stop()
	# pressed action 1. go to action 1 aim mode
	if Input.is_action_just_pressed("action_one"):
		return action_one_state
		
	return null

func process_physics(_delta: float) -> State:
	if destination.distance_to(parent.global_position) < 1 * parent.get_movement_speed()/100:
		return idle_state
	
	var direction: Vector2 = parent.global_position.direction_to(destination)
	parent.position += direction * parent.get_movement_speed() * _delta
	
	if parent.is_unconscious():
		return unconscious_state
	
	return null
	
func process_frame(_delta: float) -> State:
	if parent.is_unconscious():
		return unconscious_state
	return null
