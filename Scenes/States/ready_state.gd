extends State

## Ready State. Make and process attacks
@export
var reload_state: State

@export
var action_name: String = ""

var attack_direction_queue = []
var queued_attack_cones = []

var aim_timer: Timer


func _ready() -> void:
	aim_timer = Timer.new()
	aim_timer.one_shot = true
	aim_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	aim_timer.autostart = false
	add_child(aim_timer)
	aim_timer.timeout.connect(on_aim_finished)
	
func enter() -> void:
	super()

func exit() -> void:
	super()

func process_physics(_delta: float) -> State:
	if parent.weapon.have_bullets():
		if !attack_direction_queue.is_empty() and aim_timer.is_stopped():
			start_attack_process()
		return null
	else:
		return reload_state

func process_frame(_delta: float) -> State:
	if !aim_timer.is_stopped():
		parent.update_attack_cone((aim_timer.wait_time - aim_timer.time_left) / aim_timer.wait_time)
	return null

func process_input(_event: InputEvent) -> State:
	## action queue input
	if _event.is_action_pressed(action_name):
		if parent.weapon.ready:
			if attack_direction_queue.size() < parent.weapon.current_magazine_count:
				save_mouse_position()
				parent.bullets_changed.emit()
					
	return null

# save local mouse position vector to attack dir queue
func save_mouse_position() -> void:
	attack_direction_queue.push_back(parent.get_local_mouse_position())
	make_queued_attack_cone(attack_direction_queue.back())
	print("Attack queued. Current queue count: " + str(attack_direction_queue.size()))
	
func make_queued_attack_cone(dir: Vector2) -> void:
	var new_attack_cone: Polygon2D = Polygon2D.new()
	new_attack_cone.polygon = parent.attack_full_cone.polygon
	new_attack_cone.color = parent.queued_color
	new_attack_cone.rotate(dir.angle())
	parent.queued_cones.add_child(new_attack_cone)
	queued_attack_cones.append(new_attack_cone)
	
func start_attack_process() -> void:
	if attack_direction_queue.is_empty():
		return
	
	print("start attack process")	
	
	# back end
	aim_timer.stop()
	aim_timer.start(1)
	
	# front end
	parent.attack_full_cone.rotation = Vector2.ZERO.angle_to_point(attack_direction_queue.front())
	queued_attack_cones.front().visible = false
	parent.attack_full_cone.visible = true
	
func on_aim_finished() -> void:
	if attack_direction_queue.size() == 0:
		push_error("Aim finished but no attack direction.")
	else:
		var target: Vector2 = attack_direction_queue.pop_front()
		#parent.gunshot_sfx.stream = parent.weapon.data.equipment_use_sound
		#parent.gunshot_sfx.play()
		#parent.arm.rotation = target.angle()
		print("Attack finished. Current queue count: " + str(attack_direction_queue.size()))
		if queued_attack_cones.size() > 0:
			queued_attack_cones.pop_front().queue_free()
		parent.attack_full_cone.visible = false
		
		parent.weapon.on_activation(InputManager.selected_unit, target)
		InputManager.selected_unit.actioned.emit()
	
	# if attack direction queue has stuff in it, start next attack process
	# reload if we are out of bullets
	if !attack_direction_queue.is_empty():
		if parent.weapon.have_bullets():
			start_attack_process()
