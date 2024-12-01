extends State

## Opening state that is the paused moment before the run actually starts

@export
var wave_state: State

const start_countdown_time: float = 3
var time_til_game_start: float = start_countdown_time
var game_starting: bool = false

var starting_ui: Control
var countdown_label: Label


func _ready() -> void:
	return
	
func enter() -> void:
	starting_ui = parent.user_interface.waiting_start_ui
	countdown_label = starting_ui.get_node("StartingLabel")
	time_til_game_start = start_countdown_time
	game_starting = false
	
	# Show instructions UI
	starting_ui.visible = true
	starting_ui.get_node("Label").visible = true
	countdown_label.visible = false
	
	# reset wave stats
	parent.spawner_component.reset_stats()
	
	return

func exit() -> void:
	# Hide instructions UI
	print("***GAME START***")
	starting_ui.visible = false
	return

# start wave spawn countdown if player presses click
func process_input(_event: InputEvent) -> State:
	if !game_starting and Input.is_action_just_pressed("action_one") or Input.is_action_just_pressed("action_two"):
		# start game start countdown
		game_starting = true
		starting_ui.get_node("Label").visible = false
		countdown_label.visible = true
		countdown_label.text = "Starting in " + str(int(time_til_game_start) + 1)

	return null

func process_frame(_delta: float) -> State:
	if game_starting:
		time_til_game_start -= _delta
		countdown_label.text = "Starting in " + str(int(time_til_game_start) + 1)
		if time_til_game_start < 0:
			return wave_state
	
	return null

func process_physics(_delta: float) -> State:
	return null
