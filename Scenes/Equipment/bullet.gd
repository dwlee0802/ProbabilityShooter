extends RefCounted
class_name Bullet

var damage_amount: int = 0
var piercing: bool = false
var projectile_count: int = 1

func _to_string() -> String:
	var output = "BULLET INFO:\n"
	output += "DMG: " + str(damage_amount)
	if piercing:
		output += " PIERCING"
	return output
