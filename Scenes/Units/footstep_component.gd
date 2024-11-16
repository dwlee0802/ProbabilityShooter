extends Node
class_name FootstepComponent

var unit: RigidBody2D

@export
## minimum speed to be considered moving
var running_threshold: float = 10

var timer: Timer
var footstep_cooldown: float = 0.4
var running_offset: float = 0.2

@onready
var sound_player: AudioStreamPlayer = $FootstepSound


func _ready() -> void:
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(timer)
	timer.timeout.connect(on_footstep_timer_timeout)

func _physics_process(delta: float) -> void:
	if timer.is_stopped():
		if unit.linear_velocity.length() > running_threshold:
			# restart timer
			if unit.is_running:
				timer.start(footstep_cooldown - running_offset)
			else:
				timer.start(footstep_cooldown)
	
	if unit.linear_velocity.length() < running_threshold:
		if !timer.is_stopped():
			timer.stop()
		
func on_footstep_timer_timeout() -> void:
	sound_player.play()
