extends State

## Ready State. Make and process attacks
@export
var reload_state: State

@export
var action_name: String = ""

var aim_timer: ScalableTimer


func _ready() -> void:
	aim_timer = ScalableTimer.new()
	aim_timer.one_shot = true
	add_child(aim_timer)
	aim_timer.timeout.connect(on_aim_finished)
	
func enter() -> void:
	super()
	parent.aim_timer = aim_timer

func exit() -> void:
	super()
	parent.attack_full_cone.visible = false
	parent.clear_attack_queues()
	aim_timer.stop()

func process_physics(_delta: float) -> State:
	if parent.bullets.size() > 0 or parent.queued_bullets.size() > 0:
		if !parent.attack_direction_queue.is_empty() and aim_timer.is_stopped():
			start_attack_process()
		return null
	else:
		return reload_state

func process_frame(_delta: float) -> State:
	if !aim_timer.is_stopped():
		parent.update_attack_cone((aim_timer.max_time - aim_timer.time_left) / aim_timer.max_time)
	else:
		# make hands follow mouse
		if !parent.recoil_animation.is_playing():
			parent.point_arm_at(parent.get_local_mouse_position())
			
	return null

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("reload"):
		return reload_state
		
	## action queue input
	if _event.is_action_pressed(parent.action_name):
		if parent.has_bullets():
			save_mouse_position()
			parent.bullets_changed.emit()
	
	return null

# save local mouse position vector to attack dir queue
func save_mouse_position() -> void:
	parent.attack_direction_queue.push_back(parent.get_local_mouse_position())
	parent.queued_bullets.push_back(parent.bullets.pop_front())
	make_queued_attack_cone(parent.attack_direction_queue.back())
	print("Attack queued. Current queue count: " + str(parent.attack_direction_queue.size()))
	print("Current magazine status: " + str(parent.queued_bullets.size()) + " + " + str(parent.bullets.size()))
	
func make_queued_attack_cone(dir: Vector2) -> void:
	var new_attack_cone: Polygon2D = Polygon2D.new()
	new_attack_cone.polygon = parent.attack_full_cone.polygon
	new_attack_cone.color = parent.queued_color
	new_attack_cone.rotate(dir.angle())
	parent.queued_cones.add_child(new_attack_cone)
	parent.queued_attack_cones.append(new_attack_cone)
	
func start_attack_process() -> void:
	if parent.attack_direction_queue.is_empty():
		return
	
	#print("start attack process")	
	
	# back end
	aim_timer.stop()
	#aim_timer.start(parent.queued_bullets.front().aim_time * parent.get_aim_time_modifier())
	aim_timer.start(parent.aim_time * parent.get_aim_time_modifier())
	
	# front end
	parent.attack_full_cone.rotation = Vector2.ZERO.angle_to_point(parent.attack_direction_queue.front())
	parent.queued_attack_cones.front().visible = false
	parent.attack_full_cone.visible = true
	parent.point_arm_at(parent.attack_direction_queue.front())
	
func on_aim_finished() -> void:
	if parent.attack_direction_queue.size() == 0:
		#push_warning("Aim finished but no attack direction.")
		pass
	else:
		var target: Vector2 = parent.attack_direction_queue.pop_front()
		parent.gunshot_sfx.stream = parent.weapon_data.fire_sound
		parent.gunshot_sfx.play()
		#print("Attack finished. Current queue count: " + str(parent.attack_direction_queue.size()))
		if parent.queued_attack_cones.size() > 0:
			parent.queued_attack_cones.pop_front().queue_free()
		parent.attack_full_cone.visible = false
		
		if parent.queued_bullets.size() > 0:
			parent.shot_bullet.emit(parent.queued_bullets.front().projectile_count)
		parent.on_activation(target)
		
		parent.activated.emit()
		InputManager.selected_unit.actioned.emit()
		parent.muzzle_flash.play("muzzle_flash")
		parent.muzzle_smoke.emitting = true
		
		# left side
		if parent.arm.get_node("Node2D/Hand").flip_v == true:
			parent.recoil_animation.play("recoil_left")
		# right side
		else:
			parent.recoil_animation.play("recoil_right")
	
	# if attack direction queue has stuff in it, start next attack process
	# reload if we are out of bullets
	if !parent.attack_direction_queue.is_empty():
		if parent.has_bullets():
			start_attack_process()
