extends Gun
class_name Grenade

@export
var bonus_radius: float = 0

func get_radius() -> float:
	return data.radius + bonus_radius
	
func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	var new_bullet: EffectArea = data.projectile_scene.instantiate()
	
	# set stats
	new_bullet.duration = data.duration
	new_bullet.set_size(get_radius())
	
	if new_bullet is DamageArea:
		new_bullet.damage_per_second = data.damage_per_second
	if new_bullet is SlowArea:
		new_bullet.slow_amount = data.slow_amount
		
	#new_bullet.launch(data.mouse_position.normalized(), data.projectile_speed, randi_range(data.damage_range.x, data.damage_range.y))
	new_bullet.global_position = unit.global_position + mouse_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)

	current_magazine_count -= 1
