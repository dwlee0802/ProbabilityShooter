extends State

@export
var other_state: State


func enter() -> void:
	parent.game_paused_screen.visible = true
	get_tree().paused = true
	return

func exit() -> void:
	get_tree().paused = false
	parent.game_paused_screen.visible = false
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
