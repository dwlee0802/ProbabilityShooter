extends Control
class_name DelayedProgressBar

@onready
var health_bar: ProgressBar = $HealthBar
@onready
var damage_bar: ProgressBar = $DamageBar
@export
var delay_time: float = 1

func set_max(val: int):
	health_bar = $HealthBar
	damage_bar = $DamageBar
	health_bar.max_value = val
	damage_bar.max_value = val

func change_value(new_val: float, immediate: bool = false) -> void:
	health_bar.value = new_val
	# gradually change damage bar
	if !immediate:
		var tween = get_tree().create_tween()
		tween.tween_property(damage_bar, "value", new_val, delay_time)
		tween.bind_node(health_bar)
	else:
		# immediately change health bar
		damage_bar.value = new_val
		
	return
