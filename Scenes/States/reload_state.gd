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
	
	# start reload process

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
