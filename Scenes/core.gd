extends Area2D
class_name Core

@export var core_health: int = 300

signal core_killed

func _on_body_entered(body):
	print("core hit!")
	
	if body is EnemyUnit:
		# reduce core health
		receive_hit(body.health_points)
		
		# if core health is zero or below, emit signal
		if core_health <= 0:
			core_killed.emit()
			
		body.queue_free()

func receive_hit(amount):
	core_health -= amount
