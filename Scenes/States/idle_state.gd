extends State

@export
var move_state: State
@export
var aim_state: State


func enter() -> void:
	super()


func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
