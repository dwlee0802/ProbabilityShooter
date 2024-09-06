extends RefCounted
class_name Bullet

var damage_amount: int = 0
var projectile_count: int = 1

func _init(damage_amount_: int) -> void:
	damage_amount = damage_amount_

func _to_string() -> String:
	var output = "BULLET INFO:\n"
	output += "DMG: " + str(damage_amount)
	return output
