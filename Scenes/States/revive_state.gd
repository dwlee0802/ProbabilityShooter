extends State

@export
var idle_state: State
@export
var action_one_state: State
@export
var move_state: State
@export
var unconscious_state: State

@onready
var timer: Timer = $Timer

func enter() -> void:
	super()
	parent.state_label.text = "Reviving"
	timer.start(parent.revive_time)
	parent.attack_line.visible = false
	
func process_frame(_delta: float) -> State:
	# knocked out
	if parent.health_points <= 0:
		return unconscious_state
		
	return null

func exit() -> void:
	super()
	parent.attack_line.visible = false
	parent.attack_line_anim.stop()

func process_input(_event: InputEvent) -> State:
	if !InputManager.IsSelected(parent):
		return null
		
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		if parent.action_one_available:
			return action_one_state
		
	return null
	
func process_physics(_delta: float) -> State:
	if timer.is_stopped():
		print("revive complete")
		return idle_state
	
	return null
