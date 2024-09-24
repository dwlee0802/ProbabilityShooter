extends State

@export
var ready_state: State

var active_reload_success_sound = preload("res://Sound/UI/confirmation_002.ogg")
var active_reload_fail_sound = preload("res://Sound/UI/error_006.ogg")


func enter() -> void:
	super()
	parent.weapon.clear_bullets()
	start_reload_process()
	if !parent.reload_timer.timeout.is_connected(reload_action):
		parent.reload_timer.timeout.connect(reload_action)
	parent.bullets_changed.emit()

func process_frame(_delta: float) -> State:
	if parent.weapon.have_bullets():
		return ready_state
	return null
	
func process_input(_event: InputEvent) -> State:
	# determine active reload success
	#if Input.is_action_just_pressed("reload"):
		#check_active_reload()
		
	## click to active reload
	if !parent.reload_timer.is_stopped():
		if Input.is_action_just_pressed(parent.action_name) and parent.active_reload_available:
			check_active_reload()
			
	return null
	
func start_reload_process(_eq_num: int = 0) -> void:
	if parent.reload_timer.is_stopped():
		print("Start Reload Process")
		parent.active_reload_available = true
		parent.active_reload_failed = false
		parent.reload_timer.start(parent.weapon.data.reload_time)
		var active_reload_start_point: int = randi_range(40, 70)
		parent.active_reload_range = Vector2i(active_reload_start_point, active_reload_start_point + parent.active_reload_length)
		print("active reload range: " + str(parent.active_reload_range))
		parent.reload_started.emit()
		
func check_active_reload() -> void:
	if parent.reload_timer.is_stopped():
		return
	var timer: Timer = parent.reload_timer
	
	# determine active reload success
	print("range: " + str(parent.active_reload_range))
	var selected_point: float = (1 - timer.time_left / timer.wait_time) * 100
	print("selected: " + str(selected_point))
	if parent.active_reload_available and parent.active_reload_range.x - 3 < selected_point and selected_point < parent.active_reload_range.y + 3:
		#print("active reload success!")
		timer.stop()
		timer.timeout.emit()
		parent.active_reload_sound_player.stream = active_reload_success_sound
		parent.active_reload_sound_player.play()
	else:
		#print("active reload fail!")
		parent.active_reload_sound_player.stream = active_reload_fail_sound
		parent.active_reload_sound_player.play()
		parent.active_reload_failed = true
	
	parent.active_reload_available = false

func reload_action() -> void:
	print("Reload complete")
	parent.active_reload_available = true
	parent.weapon.reload()
	parent.reload_sfx.stream = parent.weapon.data.reload_sound
	parent.reload_sfx.play()
		
	parent.bullets_changed.emit()
	parent.reload_complete.emit()
