extends CanvasLayer
class_name UserInterface

@onready
var restart_button: Button = $GameOver/RestartButton
@onready
var game_over_ui = $GameOver
@onready
var unit_portraits: VBoxContainer = $UnitPortraits
@onready
var unit_shortcut_labels: Control = $UnitShortcutLabels

## game state
@onready
var game_time_label: Label = $GameState/GameTimeLabel
@onready
var kill_count_label: Label = $GameState/KillsLabel
@onready
var resource_label: Label = $GameState/ResourceLabel
@onready
var core_health_bar: DelayedProgressBar = $GameState/CoreHealthBar
@onready
var core_health_label: Label = $GameState/CoreHealthBar/CoreHealthLabel
@onready
var core_progress_bar: DelayedProgressBar = $GameState/CoreActivationBar
@onready
var core_progress_label: Label = $GameState/CoreActivationBar/CoreProgressLabel
@onready
var core_hit_effect: AnimationPlayer = $CoreHitEffect/AnimationPlayer


func _ready():
	game_over_ui.visible = false

func update_unit_portraits(units) -> void:
	for i in range(unit_portraits.get_child_count()):
		var portrait: UnitPortrait = unit_portraits.get_child(i)
		if i < units.size():
			portrait.set_shortcut_label(i + 1)
			portrait.set_unit(units[i])
		else:
			portrait.visible = false

func update_unit_shortcut_labels(_camera_pos: Vector2, units) -> void:
	for i in range(units.size()):
		units[i].set_shortcut_label(i + 1)

func show_game_over_screen(victory: bool = false):
	$GameOver.visible = true
	$GameOver/Fail.visible = !victory
	$GameOver/Victory.visible = victory
