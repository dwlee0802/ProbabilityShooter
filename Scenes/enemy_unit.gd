extends RigidBody2D
class_name EnemyUnit

static var core_position: Vector2

var health_points: int = 100

var movement_speed: float = 0

func on_spawn(speed):
	var core_dir = global_position.direction_to(EnemyUnit.core_position)
	apply_central_impulse(core_dir * speed)
	movement_speed = speed

func receive_hit(damage_amount: int):
	health_points -= damage_amount
	print("Received damage: " + str(damage_amount))
	if health_points <= 0:
		queue_free()

func _physics_process(delta):
	# adjust velocity to go towards core
	var current_direction: Vector2 = linear_velocity.normalized()
	var current_speed: float = linear_velocity.length()
	
	var angle_to_core: float = global_position.angle_to_point(core_position)
	var target_direction: Vector2 = linear_velocity.from_angle(angle_to_core)
	
	var adjustment_force: Vector2 = target_direction - current_direction
	
	apply_central_impulse(adjustment_force)
	
	# bring speed back to normal
	if current_speed > movement_speed:
		apply_central_impulse(-current_direction * delta)
	else:
		apply_central_impulse(current_direction * delta)
	
