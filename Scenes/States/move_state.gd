extends State

@export
var idle_state: State

func enter() -> void:
	super()
	parent.state_label.text = "Move"

func process_input(event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
		
	return null
