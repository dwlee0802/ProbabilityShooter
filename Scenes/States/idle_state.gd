extends State

@export
var move_state: State
@export
var aim_state: State
@export
var reload_state: State


func enter() -> void:
	super()
	parent.state_label.text = "Idle"
	
func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	# pressed action 1. go to action 1 aim mode
	if Input.is_action_just_pressed("action_1"):
		if parent.action_1_available:
			aim_state.action = Action.One
			return aim_state
		else:
			reload_state.action = Action.One
			return reload_state
		
	return null
	
func process_physics(_delta: float) -> State:
	return null
