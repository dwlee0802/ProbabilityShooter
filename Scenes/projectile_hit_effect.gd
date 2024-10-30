extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Star.rotate(randf_range(0, PI))
	
func critical() -> void:
	$Star.visible = true
	modulate = Color.WHITE
	
	$CPUParticles2D2.amount = 12
	$CPUParticles2D2.initial_velocity_max += 100
	$CPUParticles2D.amount = 16
	$CPUParticles2D.initial_velocity_max += 300
	$AnimationPlayer.speed_scale -= 0.25
