extends State

@export
var ready_state: State

var casings: PackedScene = preload("res://Scenes/Effects/casings.tscn")


func enter() -> void:
	super()
	parent.weapon.clear_bullets()
	start_reload_process()
	if !parent.reload_timer.timeout.is_connected(reload_action):
		parent.reload_timer.timeout.connect(reload_action)
	parent.bullets_changed.emit()

func exit() -> void:
	parent.active_reload_available = true
	parent.reload_timer.stop()
	super()
	
func process_frame(_delta: float) -> State:
	if parent.weapon.have_bullets():
		# stop reload process
		return ready_state
		
	# make hands follow mouse
	if !parent.recoil_animation.is_playing():
		parent.point_arm_at(parent.get_local_mouse_position())
			
	return null
	
func process_input(_event: InputEvent) -> State:
	# determine active reload success
	#if Input.is_action_just_pressed("reload"):
		#check_active_reload()
		
	## click to active reload
	if !parent.reload_timer.is_stopped():
		if Input.is_action_just_pressed(parent.action_name) and parent.active_reload_available:
			parent.check_active_reload_success()
			
	return null
	
func start_reload_process() -> void:
	if parent.reload_timer.is_stopped():
		print("Start Reload Process")
		parent.active_reload_available = true
		parent.active_reload_failed = false
		parent.reload_timer.start(parent.weapon.data.reload_time)
		var active_reload_start_point: int = randi_range(40, 70)
		parent.active_reload_range = Vector2i(active_reload_start_point, active_reload_start_point + parent.active_reload_length)
		print("active reload range: " + str(parent.active_reload_range))
		parent.reload_started.emit()
	
func reload_action() -> void:
	print("Reload complete")
	parent.reload()
	
	var new_casing_eff: Node2D = casings.instantiate()
	new_casing_eff.set_direction(Vector2.from_angle(parent.rotation + PI))
	new_casing_eff.global_position = parent.global_position
	parent.recoil_animation.play("reload")
	get_tree().root.get_node("Game").casings.add_child(new_casing_eff)
