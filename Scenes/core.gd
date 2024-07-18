extends Area2D
class_name Core

@export var core_health: int = 300

signal core_killed

func _on_body_entered(body):
	print("core hit!")
	
	# reduce core health
	
	# if core health is zero or below, emit signal
	if core_health <= 0:
		core_killed.emit()
