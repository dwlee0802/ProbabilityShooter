extends CanvasLayer
class_name GameOverScreen

@onready
var title_label: Label = $Control/vBoxContainer/Label

@onready
var restart_button: Button = $Control/vBoxContainer/VBoxContainer/RestartButton
@onready
var quit_button: Button = $Control/vBoxContainer/VBoxContainer/HBoxContainer/QuitButton

## Stat labels
@onready
var score_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/Score
@onready
var survival_time_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/SurvivalTime
@onready
var kill_count_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/KillCount
@onready
var level_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/Level
@onready
var damage_output: Label = $Control/vBoxContainer/StatsContainer/StatLabels/DamageOutput
@onready
var shots_count_label: Label = $Control/vBoxContainer/StatsContainer/StatLabels/ShotsCount
@onready
var reload_count: Label = $Control/vBoxContainer/StatsContainer/StatLabels/ReloadCount


func _ready() -> void:
	quit_button.pressed.connect(on_game_quit)
	
func on_game_over():
	await get_tree().create_timer(3).timeout
	visible = true

func on_game_quit():
	get_tree().quit()

func set_game_over_stats(stats_component: StatisticsComponent) -> void:
	score_label.text = str(stats_component.score)
	survival_time_label.text = str(int(stats_component.survival_time)) + "s"
	kill_count_label.text = str(int(stats_component.kill_count)) + " kills"
	level_label.text = "Lv. " + str(stats_component.level_reached) + " (" + str(stats_component.total_exp_gained) + " EXP)"
	damage_output.text = "Eff: " + str(stats_component.total_effective_damage_output) + " / Total: " + str(stats_component.total_damage_output)
	shots_count_label.text = "Normal: " + str(stats_component.bullets_hit_count - stats_component.critical_hit_count) + " Critical: " + str(stats_component.critical_hit_count) + " Total: " + str(stats_component.bullets_fired_count)
	reload_count.text = "Success: " + str(stats_component.active_reload_success_count) + " Total: " + str(stats_component.total_reload_count)

func set_title(victory: bool):
	if victory:
		title_label.text = "VICTORY"
	else:
		title_label.text = "GAME OVER"
		
