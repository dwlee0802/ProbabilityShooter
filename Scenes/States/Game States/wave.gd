extends State

@export
var other_state: State


func enter() -> void:
	# spawn wave
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	# check if wave is finished and go to shop state if so
	return null

func process_physics(_delta: float) -> State:
	return null
