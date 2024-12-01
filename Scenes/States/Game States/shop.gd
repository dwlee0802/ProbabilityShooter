extends State

@export
var other_state: State


func enter() -> void:
	# show shop screen
	parent.shop_screen.on_wave_finished()
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
