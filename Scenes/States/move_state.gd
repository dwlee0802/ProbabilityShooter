extends State

@export
var idle_state: State
@export
var action_one_state: State

var destination: Vector2


func enter() -> void:
	super()
	parent.state_label.text = "Move"
	destination = parent.get_global_mouse_position()

func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed("right_click"):
		destination = parent.get_global_mouse_position()
	# pressed action 1. go to action 1 aim mode
	if Input.is_action_just_pressed("action_one"):
		return action_one_state
		
	return null

func process_physics(_delta: float) -> State:
	if destination.distance_to(parent.global_position) < 1 * parent.movement_speed/100:
		return idle_state
	
	var direction: Vector2 = parent.global_position.direction_to(destination)
	parent.position += direction * parent.movement_speed * _delta
	
	return null
