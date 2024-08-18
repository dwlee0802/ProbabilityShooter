extends TextureRect
class_name EquipmentIcon

var target_equipment: Equipment
var reload_timer: Timer

@onready
var cooldown_shade: Control = $CooldownShadow
@onready
var ready_animation: AnimationPlayer = $ReadyTint/AnimationPlayer
	

func set_data(eq: Equipment, timer: Timer) -> void:
	target_equipment = eq
	reload_timer = timer
	reload_timer.timeout.connect(ready_animation.play.bind("reload_finished_animation"))
	$WeaponNameLabel.text = target_equipment.data.equipment_name
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	## update reload shade
	if reload_timer != null:
		if target_equipment.ready:
			cooldown_shade.anchor_bottom = 0
		else:
			cooldown_shade.anchor_bottom = (reload_timer.time_left / target_equipment.data.reload_time)
