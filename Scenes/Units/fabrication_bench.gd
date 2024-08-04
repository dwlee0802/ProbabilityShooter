extends Interactable
class_name FabricationBench

var wait_time: float = 5
var time_holder: float = 0

@export
var add_damage: int = 0
@export
var add_projectile_speed: int = 0

@onready
var progress_bar: DelayedProgressBar = $HealthBar

func _ready():
	progress_bar.set_max(wait_time)
	progress_bar.change_value(0, true)
	progress_bar.visible = false
	
# called every frame by the interactor
# returns false if process is finished
func active(_delta: float, _user: PlayerUnit) -> bool:
	progress_bar.change_value(time_holder)
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
	progress_bar.visible = true
	time_holder = 0
	progress_bar.change_value(wait_time)
	
func on_exit():
	time_holder = 0
	progress_bar.visible = false
