extends GunData
class_name ShotgunData

@export
var projectile_count: int = 1
@export
var spread: float = 0

func get_spread() -> float:
	return spread / 180.0
