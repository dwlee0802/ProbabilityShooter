extends State

var move_points_queue = []
var queued_move_lines = []

@export
var idle_state: State
@export
var action_one_state: State
@export
var unconscious_state: State

var destination: Vector2

var is_first_frame: bool = false

func enter() -> void:
	super()
	parent.state_label.text = "Move"
	destination = parent.global_position
	save_mouse_position()
	
	# cancel reload
	if !parent.action_one_reload_timer.is_stopped():
		parent.action_one_reload_timer.stop()
	
	parent.move_line.visible = true
	parent.move_line.clear_points()
	parent.move_line.add_point(Vector2.ZERO)

func exit() -> void:
	super()
	destination = parent.global_position
	parent.move_line.visible = false
	clear_movement_queues()
	
func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	# pressed action 1. go to action 1 aim mode
	if Input.is_action_just_pressed("action_one"):
		return action_one_state
		
	return null

func process_physics(_delta: float) -> State:
	if destination.distance_to(parent.global_position) < 1 * parent.get_movement_speed()/100:
		print(move_points_queue.size())
		if move_points_queue.is_empty():
			return idle_state
		else:
			destination = move_points_queue.front()
			move_points_queue.pop_front()
	
	var direction: Vector2 = parent.global_position.direction_to(destination)
	parent.position += direction * parent.get_movement_speed() * _delta
	
	if parent.is_unconscious():
		return unconscious_state
	
	return null
	
func process_frame(_delta: float) -> State:
	if parent.is_unconscious():
		return unconscious_state
		
	## movement queue input
	if InputManager.IsSelected(parent):
		if !is_first_frame and Input.is_action_just_pressed("right_click"):
			if !Input.is_physical_key_pressed(KEY_SHIFT):
				# empty attack queue
				clear_movement_queues()
				save_mouse_position()
				destination = parent.global_position
				if !parent.action_one_reload_timer.is_stopped():
					parent.action_one_reload_timer.stop()
			else:
				save_mouse_position()
				
	update_movement_lines()
	
	return null

# save local mouse position vector to move points queue
func save_mouse_position() -> void:
	move_points_queue.push_back(parent.get_global_mouse_position())
	
func update_movement_lines():
	var move_line: Line2D = parent.move_line
	move_line.clear_points()
	move_line.add_point(Vector2.ZERO)
	move_line.add_point(destination - parent.global_position)
	for pt in move_points_queue:
		move_line.add_point(pt - parent.global_position)

func clear_movement_queues():
	move_points_queue.clear()
	#for item in queued_attack_lines:
		#item.queue_free()
	#queued_attack_lines.clear()
