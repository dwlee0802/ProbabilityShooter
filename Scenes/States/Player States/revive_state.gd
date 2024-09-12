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

var target: PlayerUnit


func enter() -> void:
	super()
	parent.state_label.text = "Reviving " + str(target.name)
	print("Reviving " + str(target.name))
	timer.start(parent.revive_time)
	timer.timeout.connect(parent.add_health.bind(1))
	parent.attack_line.visible = false
	
func process_frame(_delta: float) -> State:
	# knocked out
	if parent.health_points <= 0:
		return unconscious_state
		
	if target == null:
		push_error("Revive state has no target")
		return idle_state
		
	return null

func exit() -> void:
	super()
	timer.timeout.disconnect(parent.add_health.bind(1))
	target = null

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
		if target == null:
			push_error("Revive state has no target")
			return idle_state
			
		print("revive complete")
		target.add_health(1)
		
		return idle_state
	
	return null
