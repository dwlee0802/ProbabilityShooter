extends State

@export
var idle_state: State

func enter() -> void:
	super()
	parent.state_label.text = "Unconscious"
	print(parent.name + " knocked out")

func process_frame(_delta: float) -> State:
	if !parent.is_unconscious():
		return idle_state
	print(parent.health_points)
	return null

func process_input(_event: InputEvent) -> State:
	return null
