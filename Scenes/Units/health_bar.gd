extends Control
class_name DelayedProgressBar

@export
var bar_color: Color = Color.BLUE

@onready
var health_bar: ProgressBar = $HealthBar
@onready
var damage_bar: ProgressBar = $DamageBar
@export
var delay_time: float = 0.8

func _ready():
	$HealthBar.self_modulate = bar_color
	
func set_max(val: float):
	health_bar = $HealthBar
	damage_bar = $DamageBar
	health_bar.max_value = val
	damage_bar.max_value = val

func change_value(new_val: float, immediate: bool = false) -> void:
	if new_val > 0:
		health_bar.value = new_val
		# gradually change damage bar
		if !immediate:
			var tween = get_tree().create_tween()
			tween.tween_property(damage_bar, "value", new_val, delay_time)
			tween.bind_node(health_bar)
		else:
			# immediately change health bar
			damage_bar.value = new_val
	else:
		damage_bar.value = new_val
		# gradually change damage bar
		if !immediate:
			var tween = get_tree().create_tween()
			tween.tween_property(health_bar, "value", new_val, delay_time)
			tween.bind_node(damage_bar)
		else:
			# immediately change health bar
			health_bar.value = new_val
		
	return
