extends Projectile

# damage everything inside on spawn
# queue free when animation is done
func launch(direction: Vector2, _speed: float, amount: int, knock_back: float = 0) -> void:
	var collision_shape: CollisionShape2D = $CollisionShape2D
	damage_amount = amount
	damage_amount = 100
	# set size of collision shape
	collision_shape.shape.size = Vector2(100000, 32)
	collision_shape.position = Vector2(collision_shape.shape.size.x/2, 0)
	# set sprite
	var sprite: Sprite2D = $Sprite2D
	sprite.scale = Vector2(collision_shape.shape.size.x/32, 1)
	sprite.position = Vector2(32 * sprite.scale.x / 2, 0)
	rotate(direction.angle())
	

func _process(delta):
	var hit_units = get_overlapping_bodies()
	for unit in hit_units:
		if unit is EnemyUnit:
			unit.receive_hit(100*delta)
	print(hit_units.size())
