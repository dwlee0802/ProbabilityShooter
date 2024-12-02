extends State

@export
var opening_state: State


func enter() -> void:
	# game finished. stop spawning enemies
	if !parent.spawner_component.wave_timer.is_stopped():
		parent.spawner_component.wave_timer.stop()
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
