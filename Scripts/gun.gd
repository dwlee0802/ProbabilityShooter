extends RefCounted
class_name Gun

var data: GunData
static var bullet_generator: BulletGenerator

var bullets = []

var _base_magazine_size: int = 5
var magazine_size: int = 5

func _init(_data: GunData):
	data = _data
	_base_magazine_size = data.magazine_size
	
func reload() -> void:
	return

func clear_bullets() -> void:
	return
