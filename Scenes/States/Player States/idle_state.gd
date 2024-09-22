extends State

@export
var move_state: State
@export
var action_one_state: State
@export
var unconscious_state: State
@export
var revive_state: State
@export
var interact_state: State

var keep_reloading: bool = false


func enter() -> void:
	super()
	parent.state_label.text = "Idle"

func exit() -> void:
	super()
	keep_reloading = false
		
func process_input(_event: InputEvent) -> State:
	if !InputManager.IsSelected(parent):
		return null
		
	if Input.is_action_just_pressed("action_one"):
		keep_reloading = true
		return action_one_state
		
	return null
	
func process_physics(_delta: float) -> State:
	return null

func process_frame(_delta: float) -> State:
	# auto reload
	# knocked out
	if parent.is_unconscious():
		return unconscious_state
		
	return null
