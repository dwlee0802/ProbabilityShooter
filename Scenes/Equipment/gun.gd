extends Equipment
class_name Gun

@export
var current_magazine_count: int = 5
## Speed of the projectile produced by this gun

func _init(_data: EquipmentData):
	super(_data)
	current_magazine_count = data.magazine_size
	
func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	var new_bullet: Projectile = data.projectile_scene.instantiate()
	# set stats
	new_bullet.launch(mouse_position.normalized(), data.projectile_speed, randi_range(data.damage_range.x, data.damage_range.y), data.knock_back_force)
	new_bullet.global_position = unit.global_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)
	
	current_magazine_count -= 1
	
	CameraControl.camera.ShakeScreen(10,200)

func have_bullets() -> bool:
	return current_magazine_count > 0

func reload() -> void:
	current_magazine_count = data.magazine_size
	print("reloaded " + data.equipment_name + " " + str(current_magazine_count) + "/" + str(data.magazine_size))
