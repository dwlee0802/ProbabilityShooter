extends Node2D

@export
var casing_eject_force: float = 500.0

	
func set_direction(dir: Vector2) -> void:
	var objects = $CasingObjects.get_children()
	for casing in objects:
		if casing is RigidBody2D:
			casing.linear_velocity = casing_eject_force * dir
