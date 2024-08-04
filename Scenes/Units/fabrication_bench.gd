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

@onready
var icon_sprite: Sprite2D = $ItemSprite


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
		start_slot_machine()
		
		return false
	return true
	
func on_activate():
	progress_bar.visible = true
	time_holder = 0
	progress_bar.change_value(wait_time)
	
func on_exit():
	time_holder = 0
	progress_bar.visible = false

func start_slot_machine():
	icon_sprite.visible = true
