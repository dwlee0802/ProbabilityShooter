extends Area2D
class_name Core

## Amount of damage Core can handle before being killed
@export
var health_points: int = 300

@onready
var health_label: Label = $HealthLabel

signal core_killed


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
	
