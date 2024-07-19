extends RigidBody2D
class_name EnemyUnit

static var core_position: Vector2

var health_points: int = 100

var movement_speed: float = 0

var adjust_modifier: float = 4

@onready
var health_label: Label = $HealthLabel


func on_spawn(speed: float, health: int):
	var core_dir = global_position.direction_to(EnemyUnit.core_position)
	apply_central_impulse(core_dir * speed)
	movement_speed = speed

func _ready():
	health_label.text = str(health_points)
	
func receive_hit(damage_amount: int):
	health_points -= damage_amount
	health_label.text = str(health_points)
	print("Received damage: " + str(damage_amount))
	if health_points <= 0:
		get_parent().remove_child(self)
		queue_free()

func _physics_process(delta):
	# adjust velocity to go towards core
	var current_direction: Vector2 = linear_velocity.normalized()
	var current_speed: float = linear_velocity.length()
	
	var angle_to_core: float = global_position.angle_to_point(core_position)
	var target_direction: Vector2 = linear_velocity.from_angle(angle_to_core)
	
	var adjustment_force: Vector2 = target_direction - current_direction
	
	apply_central_impulse(adjustment_force * adjust_modifier)
	
	# bring speed back to normal
	if current_speed > movement_speed:
		apply_central_impulse(abs(current_speed - movement_speed) * -current_direction * delta)
	else:
		apply_central_impulse(abs(current_speed - movement_speed) * current_direction * delta)
	
