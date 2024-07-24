extends Control
class_name UnitPortrait

@onready
var shortcut_label: Label = $PanelContainer/Image/ShortCutLabel
@onready
var animation_player: AnimationPlayer = $AnimationPlayer

var target_unit: PlayerUnit

@onready
var health_bar: DelayedProgressBar = $PanelContainer/HealthBar


func set_shortcut_label(num: int) -> void:
	shortcut_label.text = str(num)

func set_unit(unit: PlayerUnit) -> void:
	target_unit = unit
	visible = target_unit != null
	if !visible:
		return
	
	health_bar.set_max(target_unit.max_health_points)
	update_healthbar()
	
	# set portrait image
	
	# connect signals
	target_unit.was_selected.connect(animation_player.play.bind("portrait_select"))
	target_unit.deselected.connect(animation_player.play.bind("RESET"))
	target_unit.health_changed.connect(update_healthbar)

func update_healthbar():
	health_bar.change_value(target_unit.health_points)
