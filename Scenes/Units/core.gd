extends Area2D
class_name Core

@export
var game_ref: Game

## player wins the game when core activation reaches 100
## corresponds one on one to resource units
@export
var activation_progress: float = 0
var activation_max: int = 100

## Amount of damage Core can handle before being killed
@export
var health_points: int = 300

@onready
var health_label: Label = $HealthLabel

var active: bool = false
@onready
var active_particle_effect: CPUParticles2D = $ActiveParticleEffect
@onready
var progress_radial_progress: RadialProgress = $RadialProgress

signal core_killed
signal received_hit
signal progressed
signal activation_complete

func _ready():
	health_label.text = str(health_points)
	progress_radial_progress.max_value = activation_max
	
func _on_body_entered(body):
	if body is EnemyUnit:
		# reduce core health
		receive_hit(body.health_points)
		
		# if core health is zero or below, emit signal
		if health_points <= 0:
			core_killed.emit()
			
		body.queue_free()

func _process(_delta):
	active_particle_effect.emitting = active
		
func receive_hit(amount: int) -> void:
	health_points -= amount
	health_label.text = str(health_points)
	print("core hit by " + str(amount))
	received_hit.emit()
	
func increase_activation(amount: float) -> bool:
	activation_progress += amount
	if activation_progress >= activation_max:
		activation_progress = activation_max
		activation_complete.emit()
		print("?")
		return true
			
	progressed.emit()
	return false
