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
	parent.stats_component.reset_stats()
	
	parent.user_interface.visible = true
	parent.end_screen.visible = false
	
	parent.score_component.reset()
	
	# remove leftover resources
	parent.remove_objects()
	
	# reset unit stats
	var player_unit: PlayerUnit = parent.player_unit
	player_unit.reset_health()
	player_unit.reset_items()
	player_unit.reset_exp()
	player_unit.reload_action()
	player_unit.global_position = Vector2.ZERO
	player_unit.freeze = false
	player_unit.clear_inventory()
	player_unit.reset_crystals()
	player_unit.stat_component.reset_stats()
	player_unit.clear_buffs()
	
	UpgradesManager.reset_upgrades()
	
	parent.place_shootables()
	
	parent.set_safezone_active_status(true)
	player_unit.safe_zone_active = true
	parent.user_interface.kill_count_label.text = str(int(parent.stats_component.kill_count)) + " Kills"
	
	parent.user_interface.upgrade_ui.clear_icons()
	
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
