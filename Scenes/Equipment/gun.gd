extends Equipment
class_name Gun

@export
var current_magazine_count: int = 5
## Speed of the projectile produced by this gun

@export
var bonus_damage_range: Vector2i = Vector2i.ZERO
@export
var bonus_projectile_speed: int = 0


func _init(_data: EquipmentData):
	super(_data)
	current_magazine_count = data.magazine_size
	
func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	var new_bullet: Projectile = data.projectile_scene.instantiate()
	var random_spread_offset: float = randf_range(-data.get_spread()/2, data.get_spread()/2)
	# set stats
	new_bullet.launch(
		mouse_position.normalized().rotated(random_spread_offset), 
		get_projectile_speed(), 
		randi_range(get_damage_range().x, get_damage_range().y), 
		data.knock_back_force)
	new_bullet.global_position = unit.global_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)
	
	current_magazine_count -= 1
	
	CameraControl.camera.shake_screen(20,200)

func have_bullets() -> bool:
	return current_magazine_count > 0

func reload() -> void:
	current_magazine_count = data.magazine_size
	print("reloaded " + data.equipment_name + " " + str(current_magazine_count) + "/" + str(data.magazine_size))

func add_bonus_damage(bonus: Vector2i) -> void:
	bonus_damage_range += bonus
	print(data.equipment_name + " has bonus damage of " + str(bonus_damage_range))
	
func add_bonus_projectile_speed(amount: int) -> void:
	bonus_projectile_speed += amount
	print(data.equipment_name + " has bonus speed of " + str(bonus_projectile_speed))
	
func get_damage_range() -> Vector2i:
	return data.damage_range + bonus_damage_range
func get_projectile_speed() -> float:
	return data.projectile_speed + bonus_projectile_speed
