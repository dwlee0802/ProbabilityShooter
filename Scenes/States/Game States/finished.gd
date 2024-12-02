extends State

@export
var opening_state: State

var victory: bool = false


func enter() -> void:
	# game finished. stop spawning enemies
	if !parent.spawner_component.wave_timer.is_stopped():
		parent.spawner_component.wave_timer.stop()
	
	# check victory or fail
	if parent.spawner_component.is_max_waves_reached():
		victory = true
	if parent.player_unit.is_unconscious():
		victory = false
	
	parent.game_finished(victory)
	
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
