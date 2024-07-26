extends Equipment
class_name Gun

var projectile_scene = preload("res://Scenes/Units/projectile.tscn")

## Number of times the gun can be used before needing to reload.
@export
var magazine_size: int = 5
@export
var current_magazine_count: int = 5
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
	new_bullet.launch(mouse_position.normalized(), projectile_speed, randi_range(damage_range.x, damage_range.y), knock_back_force)
	new_bullet.global_position = unit.global_position
	
	# add to scene
	unit.get_tree().root.add_child(new_bullet)
	
	current_magazine_count -= 1

func have_bullets() -> bool:
	return current_magazine_count > 0

func reload() -> void:
	current_magazine_count = magazine_size
	print("reloaded " + equipment_name + " " + str(current_magazine_count) + "/" + str(magazine_size))
