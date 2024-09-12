extends State

@export
var move_state: State


func _ready() -> void:
	var new_timer: Timer = Timer.new()
	add_child(new_timer)

func enter() -> void:
	super()
	parent.state_label.text = "State: Attack"

func process_frame(_delta: float) -> State:
	return null
	
func process_input(_event: InputEvent) -> State:
	return null
	
func process_physics(_delta: float) -> State:
	# change to move state if out of range from target
	if !parent.player_inside_range():
		return move_state
		
	return null
