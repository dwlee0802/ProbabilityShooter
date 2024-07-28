extends State

var attack_direction_queue = []
var queued_attack_lines = []

@export
var wait_time: float = 1

@export
var idle_state: State
@export
var move_state: State
@export
var unconscious_state: State

@onready
var timer: Timer = $Timer

var is_first_frame: bool = false

func enter() -> void:
	super()
	is_first_frame = true
	parent.state_label.text = "Action1"
	save_mouse_position()
	
	print(parent.get_current_equipment().data.equipment_name + " " + str(parent.get_current_equipment().data.reload_time))
	if parent.get_current_equipment().ready:
		start_attack_process()
	else:
		# start reload process
		if parent.action_one_reload_timer.is_stopped():
			parent.action_one_reload_timer.start(parent.get_current_equipment().data.reload_time)
		if !parent.action_one_reload_timer.timeout.is_connected(start_attack_process):
			# start attack process when reload is done
			parent.action_one_reload_timer.timeout.connect(start_attack_process)
	
	if !parent.equipment_changed.is_connected(timer.stop):
		parent.equipment_changed.connect(timer.stop)
	if !timer.timeout.is_connected(on_aim_finished):
		timer.timeout.connect(on_aim_finished)

func start_attack_process() -> void:
	if attack_direction_queue.is_empty():
		return
	# back end
	timer.stop()
	timer.start(parent.get_current_equipment().data.aim_time)
	# front end
	parent.attack_line.set_point_position(1, attack_direction_queue.front().normalized() * 10000)
	parent.attack_line_anim.speed_scale = 1/parent.get_current_equipment().data.aim_time
	parent.attack_line.visible = true
	parent.attack_line_anim.play("RESET")
	parent.attack_line_anim.play("aim_animation")
	queued_attack_lines.front().visible = false

func exit() -> void:
	super()
	parent.attack_line.visible = false
	parent.attack_line_anim.stop()
	attack_direction_queue.clear()
	timer.stop()
	
func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed('right_click'):
		return move_state
	
	return null

func process_frame(_delta: float) -> State:
	if parent.is_unconscious():
		return unconscious_state
	
	if attack_direction_queue.is_empty():
		return idle_state
	
	## action queue input
	if InputManager.IsSelected(parent):
		if !is_first_frame and Input.is_action_just_pressed("action_one"):
			if !Input.is_physical_key_pressed(KEY_SHIFT):
				# empty attack queue
				attack_direction_queue.clear()
				for item in queued_attack_lines:
					item.queue_free()
				queued_attack_lines.clear()
				save_mouse_position()
				start_attack_process()
			else:
				save_mouse_position()
			
	is_first_frame = false
	return null
	
func on_aim_finished() -> void:
	if attack_direction_queue.size() == 0:
		push_error("Aim finished but no attack direction.")
	else:
		parent.get_current_equipment().on_activation(parent, attack_direction_queue.pop_front())
		#print("Attack finished. Current queue count: " + str(attack_direction_queue.size()))
		queued_attack_lines.pop_front().queue_free()
	
	if !parent.get_current_equipment().have_bullets():
		parent.get_current_equipment().ready = false
	
	# if attack direction queue has stuff in it, start next attack process
	# reload if we are out of bullets
	if !attack_direction_queue.is_empty():
		if parent.get_current_equipment().ready:
			start_attack_process()
		else:
			# start reload process
			print(parent.get_current_equipment().data.equipment_name + " " + str(parent.get_current_equipment().data.reload_time))
			if parent.action_one_reload_timer.is_stopped():
				parent.action_one_reload_timer.start(parent.get_current_equipment().data.reload_time)
			if !parent.action_one_reload_timer.timeout.is_connected(start_attack_process):
				# start attack process when reload is done
				parent.action_one_reload_timer.timeout.connect(start_attack_process)

# save local mouse position vector to attack dir queue
func save_mouse_position() -> void:
	attack_direction_queue.push_back(parent.get_local_mouse_position())
	make_queued_attack_line(attack_direction_queue.back())
	#print("Attack queued. Current queue count: " + str(attack_direction_queue.size()))
	#print(attack_direction_queue)

## makes one queued attack line
func make_queued_attack_line(dir: Vector2) -> void:
	var new_line: Line2D = Line2D.new()
	var points: PackedVector2Array = PackedVector2Array()
	points.resize(2)
	points[0] = Vector2.ZERO
	points[1] = dir * 100000
	new_line.points = points
	new_line.width = 10
	new_line.default_color = parent.queued_color
	parent.add_child(new_line)
	queued_attack_lines.append(new_line)
