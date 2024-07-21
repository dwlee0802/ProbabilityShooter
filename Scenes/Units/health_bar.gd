extends Control
class_name DelayedProgressBar

@onready
var health_bar: ProgressBar = $HealthBar
@onready
var damage_bar: ProgressBar = $DamageBar
@export
var delay_time: float = 1

func set_max(val: int):
	health_bar.max_value = val
	damage_bar.max_value = val

func change_value(new_val: int, immediate: bool = false) -> void:
	# immediately change health bar
	health_bar.value = new_val
	# gradually change damage bar
	if !immediate:
		var tween = get_tree().create_tween()
		tween.tween_property(damage_bar, "value", new_val, delay_time)
	else:
		damage_bar.value = new_val
		
	return
