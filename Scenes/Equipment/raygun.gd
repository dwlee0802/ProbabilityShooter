extends Gun
class_name RayGun

func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	var new_bullet: Ray = data.projectile_scene.instantiate()
	# set stats
	new_bullet.duration = data.duration
	new_bullet.launch(data.mouse_position.normalized(), data.projectile_speed, randi_range(data.damage_range.x, data.damage_range.y))
	new_bullet.global_position = unit.global_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)

	current_magazine_count -= 1
