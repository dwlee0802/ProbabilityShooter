extends RefCounted
class_name Bullet

var damage_amount: int = 0
var piercing: bool = false
var explosive: bool = false
var anti_armor: bool = false
var projectile_count: int = 1

func _to_string() -> String:
	var output = "BULLET INFO:\n"
	if projectile_count != 1:
		output += "DMG: " + str(damage_amount/projectile_count) + " x" + str(projectile_count)
	else:
		output += "DMG: " + str(damage_amount)
	if anti_armor:
		output += " AA"
	if piercing:
		output += " EXPL"
	if explosive:
		output += " EXPL"
	return output
