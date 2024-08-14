extends EquipmentData
class_name GunData

@export
var projectile_scene = preload("res://Scenes/Units/projectile.tscn")

@export_category("Stats")
## How long it takes for the action to fire after use
@export
var aim_time: float
## How long it takes to reload the action after use
@export
var reload_time: float

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
## number of projectiles spawned for each attack
@export
var projectile_count: int = 1

@export
var spread: float = 0

func get_spread_in_rad() -> float:
	return spread / 180.0 * PI
