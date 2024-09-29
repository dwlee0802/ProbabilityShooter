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
@onready
var damage_output: Label = $Control/vBoxContainer/StatsContainer/StatLabels/DamageOutput


func _ready() -> void:
	quit_button.pressed.connect(on_game_quit)
	
func on_game_over():
	await get_tree().create_timer(3).timeout
	visible = true

func on_game_quit():
	get_tree().quit()

func set_game_over_stats(stats_component: StatisticsComponent) -> void:
	survival_time_label.text = str(int(stats_component.survival_time)) + "s"
	kill_count_label.text = str(int(stats_component.kill_count)) + " kills"
	level_label.text = "Lv. " + str(stats_component.level_reached) + " (" + str(stats_component.total_exp_gained) + " EXP)"
	damage_output.text = "Effective: " + str(stats_component.total_effective_damage_output) + " / Total: " + str(stats_component.total_damage_output)
