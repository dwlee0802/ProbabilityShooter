extends Interactable
class_name FabricationBench

var wait_time: float = 5
var time_holder: float = 0

@export
var add_damage: int = 0
@export
var add_projectile_speed: int = 0

# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, _user: PlayerUnit) -> bool:
	time_holder += _delta
	if time_holder >= wait_time:
		print("complete")
		var eq: Equipment = _user.get_current_equipment()
		eq.add_bonus_damage(add_damage)
		if eq is Gun:
			eq.add_bonus_projectile_speed(add_projectile_speed)
		return false
	return true
	
func on_activate():
	time_holder = 0
	
func on_exit():
	time_holder = 0
