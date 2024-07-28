extends Projectile
class_name Ray

var duration: float = 1

# damage everything inside on spawn
# queue free when animation is done
func launch(direction: Vector2, _speed: float, amount: int, _knock_back: float = 0) -> void:
	var collision_shape: CollisionShape2D = $CollisionShape2D
	damage_amount = amount
	# set size of collision shape
	collision_shape.shape.size = Vector2(100000, 128)
	collision_shape.position = Vector2(collision_shape.shape.size.x/2, 0)
	# set sprite
	var sprite: Sprite2D = $Sprite2D
	sprite.scale = Vector2(collision_shape.shape.size.x/32/4, 4)
	sprite.position = Vector2(32 * sprite.scale.x / 2, 0)
	rotate(direction.angle())
	
	$Sprite2D/AnimationPlayer.speed_scale = 1/duration
	
	CameraControl.camera.ShakeScreen(30,10)

func _physics_process(delta):
	var hit_units = get_overlapping_bodies()
	for unit in hit_units:
		if unit is EnemyUnit:
			unit.receive_hit(damage_amount * delta)
