extends State

@export
var idle_state: State
@export
var unconscious_state: State

@export
var action_1_state: State

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
				action_1_state.mouse_position = parent.get_local_mouse_position()
				print(action_1_state.mouse_position)
				return action_1_state
				
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
		
	return null

func process_frame(_delta: float) -> State:
	if parent.is_unconscious():
		return unconscious_state
	return null
