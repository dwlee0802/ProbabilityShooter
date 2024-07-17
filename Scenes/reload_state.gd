extends State

@export
var idle_state: State
@export
var move_state: State

var action: Action = Action.None

@onready
var timer: Timer = $Timer


func enter() -> void:
	super()
	parent.state_label.text = "Reloading " + str(action)
	timer.start(2)

func process_frame(_delta: float) -> State:
	parent.state_label.text = "Reloading in " + str(int(timer.time_left + 1))
	
	if timer.is_stopped():
		print("reload complete")
		parent.action_1_available = true
		return idle_state
		
	return null
	
func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
		
	return null
