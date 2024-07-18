extends RigidBody2D
class_name EnemyUnit

static var core_position: Vector2


func on_spawn(speed):
	var core_dir = global_position.direction_to(EnemyUnit.core_position)
	apply_central_impulse(core_dir * speed)
