extends RefCounted
class_name Bullet

var aim_time: float = 1
var damage_amount: int = 1
var piercing: bool = false
var explosive: bool = false
var anti_armor: bool = false
var quickshot: bool = false
var vampire: bool = false
var fire: bool = false
var double_damage: bool = false
var projectile_count: int = 1

var color: Color


func _to_string() -> String:
	var output = ""
	if projectile_count != 1:
		output += "" + str(int(damage_amount/float(projectile_count))) + " x" + str(projectile_count)
	else:
		output += "" + str(damage_amount)
	output += "  [color=aqua]"
	if double_damage:
		output += " x2"
	if anti_armor:
		output += " AA"
	if piercing:
		output += " PIER"
	if explosive:
		output += " EXPL"
	if quickshot:
		output += " QCK"
	if fire:
		output += " FIRE"
	if vampire:
		output += " VAMP"
	output += "[/color]\n"
	
	return output

func to_string_crosshair(only_damage: bool = false) -> String:
	var output = ""
	if projectile_count != 1:
		output += "" + str(int(damage_amount/float(projectile_count))) + " x" + str(projectile_count)
	else:
		output += "" + str(damage_amount)
	if only_damage:
		return output
		
	output += "\n[color=aqua]"
	if double_damage:
		output += "x2\n"
	if anti_armor:
		output += "AA\n"
	if piercing:
		output += "PIER\n"
	if explosive:
		output += "EXPL\n"
	if quickshot:
		output += "QCK\n"
	if fire:
		output += "FIRE\n"
	if vampire:
		output += "VAMP\n"
	output += "[/color]"
	
	return output

func print_traits() -> String:
	var output: String = ""
	if double_damage:
		output += "x2\n"
	if anti_armor:
		output += "AA\n"
	if piercing:
		output += "PIER\n"
	if explosive:
		output += "EXPL\n"
	if quickshot:
		output += "QCK\n"
	if fire:
		output += "FIRE\n"
	if vampire:
		output += "VAMP\n"
	
	return output
	
