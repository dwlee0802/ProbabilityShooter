extends RigidBody2D
class_name Projectile


func Launch(direction, speed):
	apply_central_impulse(direction * speed)
