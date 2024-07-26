extends Equipment
class_name RayGun

static var projectile_scene = preload("res://Scenes/deathray.tscn")

## Number of times the gun can be used before needing to reload.
@export
var magazine_size: int = 1
## Speed of the projectile produced by this gun
@export
var projectile_speed: float
## Range of the random damage output of the projectile produced
@export
var damage_range: Vector2i
## Force of the knock-back to the target hit by the projectile
@export
var knock_back_force: float

func on_activation(unit: Unit, mouse_position: Vector2):
	# make new projectile
	var new_bullet: Projectile = projectile_scene.instantiate()
	# set stats
	new_bullet.launch(mouse_position.normalized(), projectile_speed, randi_range(1, 201))
	new_bullet.global_position = unit.global_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)
