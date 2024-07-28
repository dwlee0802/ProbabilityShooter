extends State

@export
var move_state: State
@export
var action_one_state: State
@export
var unconscious_state: State
@export
var revive_state: State
@export
var interact_state: State

var keep_reloading: bool = false


func enter() -> void:
	super()
	parent.state_label.text = "Idle"

func exit() -> void:
	super()
	if parent.action_one_reload_timer.is_stopped() == false and !keep_reloading:
		parent.action_one_reload_timer.stop()
	keep_reloading = false
		
func process_input(_event: InputEvent) -> State:
	if !InputManager.IsSelected(parent):
		return null
		
	# right clicking when Idle is move order
	if Input.is_action_just_pressed('right_click'):
		return move_state
	if Input.is_action_just_pressed("action_one"):
		keep_reloading = true
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
		if target:
			target = target.get_parent()
			if target is PlayerUnit:
				if target.is_unconscious():
					revive_state.target = target
					return revive_state
			if target is Interactable:
				interact_state.target = target
				return interact_state
			
	return null
	
func process_physics(_delta: float) -> State:
	return null

func process_frame(_delta: float) -> State:
	# auto reload
	if parent.get_current_equipment().ready == false:
		if parent.action_one_reload_timer.is_stopped():
			parent.action_one_reload_timer.start(parent.get_current_equipment().data.reload_time)
	
	# knocked out
	if parent.is_unconscious():
		return unconscious_state
		
	return null
