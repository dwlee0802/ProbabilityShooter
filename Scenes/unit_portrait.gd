extends Control
class_name UnitPortrait

@onready
var shortcut_label: Label = $PanelContainer/Image/ShortCutLabel
@onready
var animation_player: AnimationPlayer = $AnimationPlayer

var target_unit: PlayerUnit


func set_shortcut_label(num: int) -> void:
	shortcut_label.text = str(num)

func set_unit(unit: PlayerUnit):
	target_unit = unit
	visible = target_unit != null
	
	# set portrait image
	
	# connect signals
	target_unit.was_selected.connect(animation_player.play.bind("portrait_select"))
	target_unit.deselected.connect(animation_player.play.bind("RESET"))
