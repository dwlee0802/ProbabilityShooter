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

@onready
var upgrade_menu = $UpgradeMenu
var upgrade_options = []
@onready
var upgrade_option_1 = $UpgradeMenu/LevelUp/Option1
@onready
var upgrade_option_2 = $UpgradeMenu/LevelUp/Option2
@onready
var upgrade_option_3 = $UpgradeMenu/LevelUp/Option3
@onready
var upgrade_option_4 = $UpgradeMenu/LevelUp/Option4

@onready
var minimap: Minimap = $Minimap

@onready
var bullet_info_menu_container: Container = $BulletInfoMenu/MarginContainer/GridContainer
@onready
var bullet_generation_info: Control = $BulletGenerationInfoMenu

@onready
var enemy_spawn_info: Control = $EnemySpawnInfo

@onready
var charge_bar: ProgressBar = $ChargeProgressBar

@onready
var mutation_roulette: Roulette = $MutationRoulette


func _ready():
	game_over_ui.visible = false
	item_info.visible = false
	
	upgrade_options.append(upgrade_option_1)
	upgrade_options.append(upgrade_option_2)
	upgrade_options.append(upgrade_option_3)
	upgrade_options.append(upgrade_option_4)
	
	for option in upgrade_options:
		option.option_selected.connect(upgrade_option_selected)
	
	upgrade_menu.visible = false
	
	mutation_roulette.option_selected.connect(show_mutation_info)

func _process(_delta: float) -> void:
	if InputManager.selected_unit != null:
		charge_bar.value = InputManager.selected_unit.charge / InputManager.selected_unit.max_charge * 100
	
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
	
func show_mutation_info(item: Mutation):
	#item_info.visible = true
	item_info.get_node("AnimationPlayer").play("RESET")
	var item_icon: TextureRect = item_info.get_node("MarginContainer/HBoxContainer/ItemIcon")
	#item_icon.texture = item.icon
	item_icon.self_modulate = item.color
	var name_label: Label = item_info.get_node("MarginContainer/HBoxContainer/VBoxContainer/NameLabel")
	name_label.text = item.mutation_name
	var info_label: Label = item_info.get_node("MarginContainer/HBoxContainer/VBoxContainer/InfoLabel")
	info_label.text = item.description
	
	await get_tree().create_timer(UserInterface.item_info_show_time).timeout
	
	item_info.get_node("AnimationPlayer").play("item_info_fadeout_animation")

func update_wave_info(health_range: Vector2, speed_range: Vector2):
	var vec_to_range = func(vec: Vector2):
		return str(vec.x) + " - " + str(vec.y)
		
	wave_health_range_label.text = "Enemy Health Range: "  + vec_to_range.call(health_range)
	wave_speed_range_label.text = "Enemy Speed Range: "  + vec_to_range.call(speed_range)

## show upgrade menu and populate it with upgrade options
func show_upgrade_menu() -> void:
	for i in range(upgrade_options.size()):
		upgrade_options[i].set_data(InputManager.selected_unit.upgrade_options[i])
		
	upgrade_menu.visible = true

func upgrade_option_selected(data: ItemData) -> void:
	if InputManager.selected_unit == null:
		push_error("upgrade option selected but no unit selected.")
		upgrade_menu.visible = false
		return
		
	# add item to selected unit
	if !InputManager.selected_unit.is_level_up_ready():
		push_error("upgrade option selected but level up not ready.")
	else:
		InputManager.selected_unit.add_item(data)
		InputManager.selected_unit.level_up()
		show_item_info(data)
	
	# if level up is still ready after leveling up, show new options
	# otherwise, hide menu
	if !InputManager.selected_unit.is_level_up_ready():
		upgrade_menu.visible = false
	else:
		show_upgrade_menu()

func update_bullet_menu() -> void:
	DW_ToolBox.RemoveAllChildren(bullet_info_menu_container)
	if InputManager.selected_unit == null:
		return
	
	var bullets = []
	if InputManager.selected_unit.get_current_equipment() is Gun:
		bullets = InputManager.selected_unit.get_current_equipment().bullets
		
	for i in range(bullets.size()):
		var new_label: Label = Label.new()
		if i == 0:
			new_label.add_theme_color_override("font_color", Color.GREEN)
		new_label.add_theme_font_size_override("font_size", 12)
		if i < InputManager.selected_unit.get_queued_attack_count():
			new_label.add_theme_color_override("font_color", Color.YELLOW)
		new_label.text = str(bullets[i])
		bullet_info_menu_container.add_child(new_label)

func update_bullet_generation_info_menu() -> void:
	var labels_label: Label = bullet_generation_info.get_node("MarginContainer/Labels")
	var values_label: Label = bullet_generation_info.get_node("MarginContainer/Values")
	
	var gun = InputManager.selected_unit.get_current_equipment()
	
	labels_label.text = "DMG Range:\n"
	values_label.text = str(gun.get_damage_range().x) + " - " + str(gun.get_damage_range().y) + "\n"
	
	if gun.anti_armor_chance > 0:
		labels_label.text += "Anti-Armor:\n"
		values_label.text += str(int(gun.anti_armor_chance * 100)) + "%\n"
	if gun.piercing_chance > 0:
		labels_label.text += "Piercing:\n"
		values_label.text += str(int(gun.piercing_chance * 100)) + "%\n"
	if gun.explosive_chance > 0:
		labels_label.text += "Explosive:\n"
		values_label.text += str(int(gun.explosive_chance * 100)) + "%\n"
	if gun.buckshot_chance > 0:
		labels_label.text += "Buckshot:\n"
		values_label.text += str(int(gun.buckshot_chance * 100)) + "%\n"

func update_enemy_spawn_info(spawner: EnemySpawnerComponent) -> void:
	var labels_label: Label = enemy_spawn_info.get_node("MarginContainer/Labels")
	var values_label: Label = enemy_spawn_info.get_node("MarginContainer/Values")
	
	labels_label.text = "HP Range:\n"
	values_label.text = str(spawner.health_range.x) + " - " + str(spawner.health_range.y) + "\n"
	labels_label.text += "Speed Range:\n"
	values_label.text += str(spawner.move_speed_range.x) + " - " + str(spawner.move_speed_range.y) + "\n"
