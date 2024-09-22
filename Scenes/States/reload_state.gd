extends State

@export
var ready_state: State

var active_reload_length: int = 10
var active_reload_range: Vector2i = Vector2i.ZERO
@export
var active_reload_available: bool = true
var active_reload_failed: bool = false
var active_reload_success_sound = preload("res://Sound/UI/confirmation_002.ogg")
var active_reload_fail_sound = preload("res://Sound/UI/error_006.ogg")


func enter() -> void:
	super()
	start_reload_process()
	if !parent.reload_timer.timeout.is_connected(reload_action):
		parent.reload_timer.timeout.connect(reload_action)

func process_frame(_delta: float) -> State:
	if parent.weapon.have_bullets():
		return ready_state
	return null
	
func start_reload_process(_eq_num: int = 0) -> void:
	if parent.reload_timer.is_stopped():
		print("Start Reload Process")
		active_reload_available = true
		active_reload_failed = false
		parent.reload_timer.start(parent.weapon.data.reload_time)
		var active_reload_start_point: int = randi_range(50, 70)
		active_reload_range = Vector2i(active_reload_start_point, active_reload_start_point + active_reload_length)
		#print("active reload range: " + str(active_reload_range))
		parent.reload_started.emit()
		
func check_active_reload() -> void:
	if parent.reload_timer.is_stopped():
		return
	var timer: Timer = parent.reload_timer
	
	# determine active reload success
	#print("range: " + str(active_reload_range))
	var selected_point: float = (1 - timer.time_left / timer.wait_time) * 100
	#print("selected: " + str(selected_point))
	if active_reload_available and active_reload_range.x < selected_point + 2 and selected_point - 2 < active_reload_range.y:
		print("active reload success!")
		timer.stop()
		timer.timeout.emit()
		#active_reload_sound_player.stream = active_reload_success_sound
		#active_reload_sound_player.play()
	else:
		print("active reload fail!")
		#active_reload_sound_player.stream = active_reload_fail_sound
		#active_reload_sound_player.play()
		active_reload_failed = true
	
	active_reload_available = false

func reload_action() -> void:
	print("Reload complete")
	active_reload_available = true
	parent.weapon.reload()
	#reload_sfx.stream = equipments[eq_num].data.reload_sound
	#reload_sfx.play()
		
	parent.bullets_changed.emit()
	parent.reload_complete.emit()
