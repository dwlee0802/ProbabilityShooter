extends Resource
class_name GunData

@export_category("Info")
## name of the equipment
@export
var equipment_name: String
## ui image of equipment
@export
var fire_sound: AudioStream
@export
var reload_sound: AudioStream
@export
var projectile_scene = preload("res://Scenes/Units/projectile.tscn")

@export_category("Stats")
@export
var magazine_size: int = 5
## How long it takes for the action to fire after use
@export
var aim_time: float
## How long it takes to reload the action after use
@export
var reload_time: float
## Number of times the gun can be used before needing to reload.
@export_category("Bullet Stats")
## Speed of the projectile produced by this gun
@export
var projectile_speed: float
## Force of the knock-back to the target hit by the projectile
@export
var knock_back_force: float
## number of projectiles spawned for each attack
@export
var projectile_count: int = 1
## Inaccuracy of shooting
@export
var spread: float = 0

func get_spread_in_rad() -> float:
	return spread / 180.0 * PI
