extends State

@export
var idle_state: State

@export
var action_1_state: State
@export
var action_2_state: State

var action: Action = Action.None


func enter() -> void:
	super()
	parent.state_label.text = "Aim"

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed('left_click'):
		match action:
			Action.None:
				push_error("No action index in aim state.")
				return idle_state
			Action.One:
				return action_1_state
			Action.Two:
				return action_2_state
				
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
		
	return null
