extends Area2D
class_name Projectile

var dir: Vector2
var speed: float

var damage_amount: int = 0

var knock_back_amount: float = 800

var lifetime: float = 0
# deletes self after this time
var lifetime_limit: float = 10

func launch(direction: Vector2, _speed: float, amount: int, _knock_back: float = 0) -> void:
	knock_back_amount = _knock_back
	dir = direction
	speed = _speed
	damage_amount = amount
	
func _physics_process(delta):
	position += delta * speed * dir
	lifetime += delta
	if lifetime_limit < lifetime:
		queue_free()

# hit something
func _on_body_entered(body) -> void:
	if body is EnemyUnit:
		# apply damage
		body.receive_hit(damage_amount)
		# apply knock-back
		body.apply_central_impulse(dir.normalized() * knock_back_amount)
		
	queue_free()
