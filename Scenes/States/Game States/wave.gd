extends State

@export
var shop_state: State
@export
var finished_state: State
@export
var paused_state: State


func enter() -> void:
	# spawn wave
	print("Start wave!")
	parent.spawner_component.on_wave_timer_timeout()
	parent.user_interface.wave_start_ui.wave_start(parent.spawner_component.wave_count)
	
	parent.player_unit.reload_action()
	
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	# check if wave is finished and go to shop state if so
	return null

func process_physics(_delta: float) -> State:
	if parent.is_all_enemies_killed():
		print("Wave complete!")
		if parent.spawner_component.is_max_waves_reached():
			return finished_state
		else:
			return shop_state
			
	return null
