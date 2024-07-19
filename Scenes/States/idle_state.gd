extends State

@export
var move_state: State
@export
var action_one_state: State


func enter() -> void:
	super()
	parent.state_label.text = "Idle"
	
func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		if parent.action_one_available:
			return action_one_state
		
	return null
	
func process_physics(_delta: float) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null
