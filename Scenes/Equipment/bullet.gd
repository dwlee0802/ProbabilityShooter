extends RefCounted
class_name Bullet

var aim_time: float = 1
var damage_amount: int = 0
var piercing: bool = false
var explosive: bool = false
var anti_armor: bool = false
var quickshot: bool = false
var projectile_count: int = 1

var color: Color


func _to_string() -> String:
	var output = ""
	if projectile_count != 1:
		output += "" + str(int(damage_amount/float(projectile_count))) + " x" + str(projectile_count)
	else:
		output += "" + str(damage_amount)
	output += "\n[color=yellow]"
	if anti_armor:
		output += " AA"
	if piercing:
		output += " PIER"
	if explosive:
		output += " EXPL"
	if quickshot:
		output += " QCK"
	output += "[/color]"
	
	return output
