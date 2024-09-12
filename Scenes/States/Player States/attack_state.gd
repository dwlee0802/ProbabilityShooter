extends State

var attack_direction_queue = []
var queued_attack_lines = []
var queued_attack_cones = []

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
var this_frame: bool = false

func enter() -> void:
	super()
	is_first_frame = true
	parent.state_label.text = "Action1"
	
	if parent.get_current_equipment().ready or !parent.active_reload_available:
		save_mouse_position()
	
	if parent.get_current_equipment().ready:
		if parent.get_current_equipment() is Gun:
			start_attack_process()
		elif parent.get_current_equipment() is Effector:
			on_aim_finished()
	else:
		if !parent.action_one_reload_timer.timeout.is_connected(start_attack_process):
			# start attack process when reload is done
			parent.action_one_reload_timer.timeout.connect(start_attack_process)
			
	if !parent.reload_started.is_connected(stop_attack_process):
		# stop attack process when manual reload is pressed
		parent.reload_started.connect(stop_attack_process)
	if !parent.reload_complete.is_connected(start_attack_process):
		# start attack process when reload is done
		parent.reload_complete.connect(start_attack_process)
	
	if !parent.equipment_changed.is_connected(timer.stop):
		parent.equipment_changed.connect(timer.stop)
		parent.equipment_changed.connect(clear_attack_queues)
	if !timer.timeout.is_connected(on_aim_finished):
		timer.timeout.connect(on_aim_finished)

func start_attack_process() -> void:
	print("start attack process")
	if attack_direction_queue.is_empty():
		return
	# back end
	timer.stop()
	timer.start(parent.get_aim_time())
	# front end
	parent.attack_line.set_point_position(1, attack_direction_queue.front().normalized() * 10000)
	parent.attack_full_cone.rotation = Vector2.ZERO.angle_to_point(attack_direction_queue.front())
	parent.attack_line_anim.speed_scale = 1/parent.get_aim_time()
	#parent.attack_line.visible = true
	parent.attack_line_anim.play("RESET")
	parent.attack_line_anim.play("aim_animation")
	queued_attack_lines.front().visible = false
	queued_attack_cones.front().visible = false
	parent.attack_full_cone.visible = true

func stop_attack_process() -> void:
	timer.stop()
	parent.attack_full_cone.visible = false
	if !queued_attack_cones.is_empty():
		queued_attack_cones.front().visible = true
	
func exit() -> void:
	super()
	parent.attack_line.visible = false
	parent.attack_full_cone.visible = false
	parent.attack_line_anim.stop()
	clear_attack_queues()
	timer.stop()
	
func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed('right_click'):
		return move_state
	
	## action queue input
	if _event is InputEventMouseButton and _event.is_pressed():
		if InputManager.IsSelected(parent):
			if !is_first_frame:
				if Input.is_action_just_pressed("action_one"):
					if parent.get_current_equipment().ready:
						if parent.get_queued_attack_count() < parent.get_current_equipment().current_magazine_count:
							save_mouse_position()
							parent.bullets_changed.emit()
					else:
						if !parent.active_reload_available:
							if parent.get_queued_attack_count() < parent.get_current_equipment().get_magazine_size():
								save_mouse_position()
								parent.bullets_changed.emit()
							
					#if !Input.is_physical_key_pressed(KEY_SHIFT):
						## empty attack queue
						#clear_attack_queues()
						#
						#save_mouse_position()
						#if parent.get_current_equipment().ready:
							#start_attack_process()
					#else:
						#save_mouse_position()
						
					# dont go above mag size
	
	return null

func process_frame(_delta: float) -> State:
	if parent.is_unconscious():
		return unconscious_state
	
	if attack_direction_queue.is_empty():
		return idle_state
	
	if !timer.is_stopped() and parent.get_current_equipment() is Gun:
		parent.update_attack_cone((timer.wait_time - timer.time_left) / timer.wait_time)
			
	is_first_frame = false
	return null
	
func on_aim_finished() -> void:
	if attack_direction_queue.size() == 0:
		push_error("Aim finished but no attack direction.")
	else:
		var target: Vector2 = attack_direction_queue.pop_front()
		if parent.get_current_equipment() is Gun:
			parent.gunshot_sfx.stream = parent.get_current_equipment().data.equipment_use_sound
			parent.gunshot_sfx.play()
			parent.arm.rotation = target.angle()
			#print("Attack finished. Current queue count: " + str(attack_direction_queue.size()))
			if queued_attack_lines.size() > 0:
				queued_attack_lines.pop_front().queue_free()
			if queued_attack_cones.size() > 0:
				queued_attack_cones.pop_front().queue_free()
			parent.attack_full_cone.visible = false
		parent.get_current_equipment().on_activation(parent, target)
		parent.actioned.emit()
		
		parent.charge += 30
	
	if parent.get_current_equipment() is Gun:
		if !parent.get_current_equipment().have_bullets():
			parent.get_current_equipment().ready = false
	
	# if attack direction queue has stuff in it, start next attack process
	# reload if we are out of bullets
	if !attack_direction_queue.is_empty():
		if parent.get_current_equipment().ready:
			start_attack_process()
		else:
			if !parent.action_one_reload_timer.timeout.is_connected(start_attack_process):
				# start attack process when reload is done
				parent.action_one_reload_timer.timeout.connect(start_attack_process)

# save local mouse position vector to attack dir queue
func save_mouse_position() -> void:
	attack_direction_queue.push_back(parent.get_local_mouse_position())
	make_queued_attack_line(attack_direction_queue.back())
	make_queued_attack_cone(attack_direction_queue.back())
	print("Attack queued. Current queue count: " + str(attack_direction_queue.size()))
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
	
	# disabled
	new_line.visible = false
	
	parent.add_child(new_line)
	queued_attack_lines.append(new_line)
	
func make_queued_attack_cone(dir: Vector2) -> void:
	var new_attack_cone: Polygon2D = Polygon2D.new()
	new_attack_cone.polygon = parent.attack_full_cone.polygon
	new_attack_cone.color = parent.queued_color
	new_attack_cone.rotate(dir.angle())
	parent.queued_cones.add_child(new_attack_cone)
	queued_attack_cones.append(new_attack_cone)
	
func clear_attack_queues():
	attack_direction_queue.clear()
	for item in queued_attack_lines:
		item.queue_free()
	queued_attack_lines.clear()
	for item in queued_attack_cones:
		item.queue_free()
	queued_attack_cones.clear()
	
