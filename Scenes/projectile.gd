extends Area2D
class_name Projectile

var dir: Vector2
var speed: float

var damage_amount: int = 0

var knock_back_amount: float = 300

func launch(direction: Vector2, _speed: float, amount: int) -> void:
	dir = direction
	speed = _speed
	damage_amount = amount
	
func _physics_process(delta):
	position += delta * speed * dir

# hit something
func _on_body_entered(body) -> void:
	if body is EnemyUnit:
		# apply damage
		body.receive_hit(damage_amount)
		# apply knock-back
		body.apply_central_impulse(dir.normalized() * knock_back_amount)
		
	queue_free()