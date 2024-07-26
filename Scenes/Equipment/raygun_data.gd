extends GunData
class_name RayGunData

## How long the ray exists for in game world
## damage is applied per second
@export
var duration: float = 1.0
## width of the ray
@export
var width: int = 128

func _init():
	projectile_scene = preload("res://Scenes/Equipment/deathray.tscn")
