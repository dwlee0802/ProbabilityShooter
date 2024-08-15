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
@onready
var experience_bar: DelayedProgressBar = $ExperienceBar
@onready
var experience_label: Label = $ExperienceBar/ExperienceBarLabel

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

## wave info
@onready
var wave_health_range_label: Label = $WaveInfo/MarginContainer/HBoxContainer/EnemyHealthRangeLabel
@onready
var wave_speed_range_label: Label = $WaveInfo/MarginContainer/HBoxContainer/EnemySpeedRangeLabel
@onready
var wave_pulse_enemy_rate_label: Label = $WaveInfo/MarginContainer/HBoxContainer/PulseEnemyRatioLabel

@onready
var interaction_label: Label = $InteractionLabel
@onready
var item_info: Control = $NewItemInfo
## fade out after this amount of seconds
static var item_info_show_time: float = 3

func _ready():
	game_over_ui.visible = false
	item_info.visible = false

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

func show_item_info(item: ItemData):
	#item_info.visible = true
	item_info.get_node("AnimationPlayer").play("RESET")
	var item_icon: TextureRect = item_info.get_node("MarginContainer/HBoxContainer/ItemIcon")
	#item_icon.texture = item.icon
	item_icon.self_modulate = item.color
	var name_label: Label = item_info.get_node("MarginContainer/HBoxContainer/VBoxContainer/NameLabel")
	name_label.text = item.item_name
	var info_label: Label = item_info.get_node("MarginContainer/HBoxContainer/VBoxContainer/InfoLabel")
	info_label.text = item.description
	
	await get_tree().create_timer(UserInterface.item_info_show_time).timeout
	
	item_info.get_node("AnimationPlayer").play("item_info_fadeout_animation")

func update_wave_info(health_range: Vector2, speed_range: Vector2, pulse_enemy_rate: float):
	var vec_to_range = func(vec: Vector2):
		return str(vec.x) + " - " + str(vec.y)
		
	wave_health_range_label.text = "Enemy Health Range: "  + vec_to_range.call(health_range)
	wave_speed_range_label.text = "Enemy Speed Range: "  + vec_to_range.call(speed_range)
	wave_pulse_enemy_rate_label.text = "Lunger Spawn Rate: "  + str(int(pulse_enemy_rate * 100)) + "%"
