extends State

@export
var wave_state: State

var player_pressed_next: bool = false


func enter() -> void:
	# show shop screen
	player_pressed_next = false
	if !parent.shop_screen.next_button.pressed.is_connected(on_next_pressed):
		parent.shop_screen.next_button.pressed.connect(on_next_pressed)
	parent.shop_screen.on_wave_finished()
	return

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	if player_pressed_next:
		return wave_state
		
	return null

func on_next_pressed() -> void:
	print("next button pressed")
	player_pressed_next = true
	
func process_physics(_delta: float) -> State:
	return null
