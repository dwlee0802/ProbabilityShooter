extends CanvasLayer
class_name UserInterface

@onready
var restart_button: Button = $GameOver/RestartButton
@onready
var game_over_ui = $GameOver
@onready
var experience_bar: DelayedProgressBar = $ExperienceBar
var exp_popup = preload("res://Scenes/Effects/exp_popup.tscn")
@onready
var experience_label: Label = $ExperienceBar/ExperienceBarLabel

## game state
@onready
var game_time_label: Label = $GameState/GameTimeLabel
@onready
var kill_count_label: Label = $GameState/KillsLabel
@onready
var kill_count_animation: AnimationPlayer = $GameState/KillsLabel/AnimationPlayer
@onready
var resource_label: Label = $GameState/ResourceLabel
@onready
var core_health_bar: DelayedProgressBar = $CoreHealthBar
@onready
var core_health_label: Label = $CoreHealthBar/CoreHealthLabel
@onready
var core_progress_bar: DelayedProgressBar = $GameState/CoreActivationBar
@onready
var core_progress_label: Label = $GameState/CoreActivationBar/CoreProgressLabel
@onready
var core_hit_effect: AnimationPlayer = $CoreHitEffect/AnimationPlayer

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
var left_bullet_info_menu_container: Container = $LeftBulletInfoMenu/MarginContainer/GridContainer
@onready
var right_bullet_info_menu_container: Container = $RightBulletInfoMenu/MarginContainer/GridContainer
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
	DW_ToolBox.RemoveAllChildren(left_bullet_info_menu_container)
	if InputManager.selected_unit == null:
		return
	
	var bullets = []
	if InputManager.selected_unit.get_current_equipment() is Gun:
		bullets = InputManager.selected_unit.get_current_equipment().bullets
		
	for i in range(bullets.size()):
		var new_label: RichTextLabel = RichTextLabel.new()
		new_label.fit_content = true
		new_label.scroll_active = false
		new_label.bbcode_enabled = true
		new_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i == 0:
			new_label.add_theme_color_override("font_color", Color.GREEN)
		new_label.add_theme_font_size_override("font_size", 12)
		if i < InputManager.selected_unit.get_queued_attack_count():
			new_label.add_theme_color_override("font_color", Color.YELLOW)
		new_label.text = str(bullets[i])
		left_bullet_info_menu_container.add_child(new_label)

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
	if gun.quickshot_chance > 0:
		labels_label.text += "Quickshot:\n"
		values_label.text += str(int(gun.quickshot_chance * 100)) + "%\n"

func update_enemy_spawn_info(spawner: EnemySpawnerComponent) -> void:
	var labels_label: Label = enemy_spawn_info.get_node("MarginContainer/Labels")
	var values_label: Label = enemy_spawn_info.get_node("MarginContainer/Values")
	
	labels_label.text = "Spawn Rate:\n"
	values_label.text = str(DW_ToolBox.TrimDecimalPoints(1/spawner.spawn_cooldown, 1)) + " per second\n"
	labels_label.text += "Wave Chance:\n"
	values_label.text += str(int(spawner.wave_chance * 1000)/10.0) + "%\n"
	labels_label.text += "HP Range:\n"
	values_label.text += str(spawner.health_range.x) + " - " + str(spawner.health_range.y) + "\n"
	labels_label.text += "Speed Range:\n"
	values_label.text += str(spawner.move_speed_range.x) + " - " + str(spawner.move_speed_range.y) + "\n"
	if spawner.heavy_chance != 0:
		labels_label.text += "Heavy:\n"
		values_label.text += str(int(spawner.heavy_chance*1000)/10.0) + "%\n"
	if spawner.fast_chance != 0:
		labels_label.text += "Fast:\n"
		values_label.text += str(int(spawner.fast_chance*1000)/10.0) + "%\n"

func make_exp_popup(amount: int) -> void:
	var new_popup = exp_popup.instantiate()
	new_popup.get_node("Label").text = "+" + str(amount)
	experience_bar.add_child(new_popup)
