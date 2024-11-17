extends Node

@export
var ghost_cooldown: float = 4
@export
var ghost_duration: float = 2
var ghost_timer: Timer
var ghost_duration_timer: Timer

@onready
var ghost_animation: AnimationPlayer = $GhostAnimationPlayer


func _ready() -> void:
	ghost_timer = Timer.new()
	ghost_timer.autostart = true
	ghost_timer.one_shot = true
	add_child(ghost_timer)
	ghost_timer.timeout.connect(ghost)
	ghost_timer.start(ghost_cooldown)
	
	ghost_duration_timer = Timer.new()
	ghost_duration_timer.autostart = false
	ghost_duration_timer.one_shot = true
	add_child(ghost_duration_timer)
	ghost_duration_timer.timeout.connect(unghost)

func ghost() -> void:
	ghost_animation.play("ghost")
	ghost_duration_timer.start(ghost_duration)
	get_parent().collision_layer = 2048

func unghost() -> void:
	ghost_animation.play("unghost")
	ghost_timer.start(ghost_cooldown)
	get_parent().collision_layer = 2048 + 8
