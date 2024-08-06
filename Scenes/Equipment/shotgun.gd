extends Gun
class_name Shotgun


func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	for i in range(data.projectile_count):
		var new_bullet: Projectile = data.projectile_scene.instantiate()
		# set stats
		new_bullet.launch(
			mouse_position.normalized().rotated(randf_range(-data.get_spread()/2.0, data.get_spread()/2.0)), 
			get_projectile_speed(), 
			randi_range(get_damage_range().x, get_damage_range().y), 
			data.knock_back_force)
		new_bullet.global_position = unit.global_position
		
		# add to scene
		unit.get_tree().root.add_child(new_bullet)
		
	current_magazine_count -= 1
	
	CameraControl.camera.shake_screen(20,200)
