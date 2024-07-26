extends Gun
class_name RayGun

## How long the ray exists for in game world
## damage is applied per second
@export
var duration: float = 1.0

func _init():
	projectile_scene = preload("res://Scenes/deathray.tscn")
	
func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	var new_bullet: Projectile = projectile_scene.instantiate()
	# set stats
	new_bullet.duration = duration
	new_bullet.launch(mouse_position.normalized(), projectile_speed, randi_range(damage_range.x, damage_range.y))
	new_bullet.global_position = unit.global_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)

	current_magazine_count -= 1
