extends State

@export
var idle_state: State

func enter() -> void:
	super()

func process_frame(_delta: float) -> State:
	if parent.health_points > 0:
		return idle_state
	return null
	
func process_input(_event: InputEvent) -> State:
	return null
