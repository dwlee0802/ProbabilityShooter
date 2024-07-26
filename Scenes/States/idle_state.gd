extends State

@export
var move_state: State
@export
var action_one_state: State
@export
var unconscious_state: State
@export
var revive_state: State


func enter() -> void:
	super()
	parent.state_label.text = "Idle"

func exit() -> void:
	super()
	if parent.action_one_reload_timer.is_stopped() == false:
		parent.action_one_reload_timer.stop()
		
func process_input(_event: InputEvent) -> State:
	if !InputManager.IsSelected(parent):
		return null
		
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		if parent.get_current_equipment().ready:
			return action_one_state
	if Input.is_action_just_pressed("interact"):
		# if its player unit and they're downed, revive
		var items = parent.interaction_area.get_overlapping_areas()
		# get closest thing inside interaction area
		var target
		var dist = INF
		for interactable in items:
			if dist > interactable.global_position.distance_to(parent.global_position):
				dist = interactable.global_position.distance_to(parent.global_position)
				target = interactable
		target = target.get_parent()
		if target is PlayerUnit:
			if target.is_unconscious():
				revive_state.target = target
				return revive_state
			
	return null
	
func process_physics(_delta: float) -> State:
	return null

func process_frame(_delta: float) -> State:
	# auto reload
	if parent.get_current_equipment().ready == false:
		if parent.action_one_reload_timer.is_stopped():
			parent.action_one_reload_timer.start(parent.get_current_equipment().reload_time)
	
	# knocked out
	if parent.is_unconscious():
		return unconscious_state
		
	return null
