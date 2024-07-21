extends CanvasLayer
class_name UserInterface

@onready
var restart_button: Button = $GameOver/RestartButton
@onready
var game_over_ui = $GameOver
@onready
var core_health_label: Label = $CoreHealthLabel
@onready
var unit_portraits: VBoxContainer = $UnitPortraits
@onready
var unit_shortcut_labels: Control = $UnitShortcutLabels

## game state
@onready
var game_time_label: Label = $GameState/GameTimeLabel
@onready
var kill_count_label: Label = $GameState/KillsLabel


func _ready():
	game_over_ui.visible = false

func update_unit_portraits(units) -> void:
	for i in range(unit_portraits.get_child_count()):
		var portrait: UnitPortrait = unit_portraits.get_child(i)
		portrait.set_shortcut_label(i + 1)
		portrait.set_unit(units[i])

func update_unit_shortcut_labels(_camera_pos: Vector2, units) -> void:
	for i in range(units.size()):
		units[i].set_shortcut_label(i + 1)
