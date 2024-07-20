extends CanvasLayer
class_name UserInterface

var reload_labels = []

@onready
var restart_button: Button = $GameOver/RestartButton
@onready
var game_over_ui = $GameOver
@onready
var core_health_label: Label = $CoreHealthLabel
@onready
var unit_portraits: VBoxContainer = $UnitPortraits

func _ready():
	reload_labels = $ReloadState.get_children()
	game_over_ui.visible = false

## reload the reload labels texts
func update_reload_labels(times) -> void:
	for i: int in range(reload_labels.size()):
		reload_labels[i].visible = i < times.size()
		if reload_labels[i].visible:
			if times[i] == 0:
				reload_labels[i].text = "SHOOT READY"
			else:
				reload_labels[i].text = "Reloading(" + str(int(times[i] * 100)/100.0) + ")"

func update_unit_portraits(units) -> void:
	for i in range(unit_portraits.get_child_count()):
		var portrait: UnitPortrait = unit_portraits.get_child(i)
		portrait.set_shortcut_label(i + 1)
		portrait.set_unit(units[i])
