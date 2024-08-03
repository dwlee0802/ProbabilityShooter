extends Area2D
class_name Core

## player wins the game when core activation reaches 100
@export
var activation_progress: float = 0
var activation_max: int = 100

## Amount of damage Core can handle before being killed
@export
var health_points: int = 300

@onready
var health_label: Label = $HealthLabel

signal core_killed
signal received_hit
signal progressed
signal activation_complete

func _ready():
	health_label.text = str(health_points)
	
func _on_body_entered(body):
	if body is EnemyUnit:
		# reduce core health
		receive_hit(body.health_points)
		
		# if core health is zero or below, emit signal
		if health_points <= 0:
			core_killed.emit()
			
		body.queue_free()

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
