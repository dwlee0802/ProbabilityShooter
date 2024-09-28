extends CanvasLayer
class_name GameOverScreen

@onready
var restart_button: Button = $Control/vBoxContainer/VBoxContainer/RestartButton
@onready
var quit_button: Button = $Control/vBoxContainer/VBoxContainer/HBoxContainer/QuitButton

## Stat labels
@onready
var survival_time_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/SurvivalTime
@onready
var kill_count_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/KillCount
@onready
var level_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/Level


func _ready() -> void:
	quit_button.pressed.connect(on_game_quit)
	
func on_game_over():
	await get_tree().create_timer(3).timeout
	visible = true

func on_game_quit():
	get_tree().quit()
