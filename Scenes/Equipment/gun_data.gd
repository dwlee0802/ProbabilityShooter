extends EquipmentData
class_name GunData

var projectile_scene = preload("res://Scenes/Units/projectile.tscn")

## Number of times the gun can be used before needing to reload.
@export
var magazine_size: int = 5
## Speed of the projectile produced by this gun
@export
var projectile_speed: float
## Range of the random damage output of the projectile produced
@export
var damage_range: Vector2i
## Force of the knock-back to the target hit by the projectile
@export
var knock_back_force: float