extends State

@export
var idle_state: State

@onready
var timer: Timer = $Timer


func enter() -> void:
	super()
	parent.state_label.text = "Action1"
	timer.start(2)

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
		 
	return null

func process_frame(_delta: float) -> State:
	parent.state_label.text = "Action1 in " + str(int(timer.time_left + 1))
	return null
	
func process_physics(_delta: float) -> State:
	if timer.is_stopped():
		print("action activated")
		return idle_state
	
	return null
