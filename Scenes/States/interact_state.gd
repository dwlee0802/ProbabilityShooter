extends State

@export
var idle_state: State
@export
var action_one_state: State
@export
var move_state: State
@export
var unconscious_state: State

var target: Interactable


func enter() -> void:
	super()
	parent.state_label.text = "Interacting with " + str(target.name)
	print("Interacting with " + str(target.name))
	parent.attack_line.visible = false
	
func process_frame(_delta: float) -> State:
	# knocked out
	if parent.health_points <= 0:
		return unconscious_state
		
	if target == null:
		push_error("Interact state has no target")
		return idle_state
		
	return null

func exit() -> void:
	super()
	target = null

func process_input(_event: InputEvent) -> State:
	if !InputManager.IsSelected(parent):
		return null
		
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		if parent.action_one_available:
			return action_one_state
		
	return null
