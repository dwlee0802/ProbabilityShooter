extends CanvasLayer
class_name UserInterface

@onready
var experience_bar: DelayedProgressBar = $HUD/VBoxContainer/VBoxContainer/ExperienceBar
var exp_popup = preload("res://Scenes/Effects/exp_popup.tscn")
@onready
var experience_label: Label = $HUD/VBoxContainer/VBoxContainer/ExperienceBar/ExperienceBarLabel
@onready
var charge_bar: DelayedProgressBar = $HUD/VBoxContainer/VBoxContainer/EnergyBar
@onready
var ability_full_label: Label = $HUD/VBoxContainer/VBoxContainer/EnergyBar/AbilityFullLabel
@onready
var charge_bar_label: Label = $HUD/VBoxContainer/VBoxContainer/EnergyBar/EnergyLabel
@onready
var charge_bar_shade: ColorRect = $HUD/VBoxContainer/VBoxContainer/EnergyBar/ColorRect2
@onready
var ability_screen_effect: Control = $SpeedEffect

@onready
var waiting_start_ui: Control = $WaitingStartUI

@onready
var wave_start_ui: WaveStartUI = $WaveStartUI

@onready
var wave_label: Label = $GameState/WaveLabel
@onready
var wave_time_label: Label = $GameState/NextWaveTimeLabel/NextWaveTimeLabel

@onready
var inventory_slots: Control = $HUD/VBoxContainer/InventorySlots
var item_slot: PackedScene = preload("res://Scenes/Interface/item_slot.tscn")

## game state
@onready
var game_time_label: Label = $GameState/GameTimeLabel
@onready
var kill_count_label: Label = $GameState/KillsLabel/KillsLabel
@onready
var kill_count_animation: AnimationPlayer = $GameState/KillsLabel/KillsLabel/AnimationPlayer
@onready
var enemy_count_label: Label = $EnemyCountLabel
@onready
var core_hit_effect: AnimationPlayer = $CoreHitEffect/AnimationPlayer
@onready
var danger_zone_effect: AnimationPlayer = $SafeZoneEffect/AnimationPlayer

@onready
var player_health_hearts: HealthHearts = $HealthScoreContainer/HealthHearts

@onready
var interaction_label: Label = $InteractionLabel
@onready
var item_info: Control = $NewItemInfo
## fade out after this amount of seconds
static var item_info_show_time: float = 3

@onready
var screen_blink: AnimationPlayer = $ShootingScreenBlink/AnimationPlayer

@onready
var upgrade_options = []
@onready
var level_up_menu: Control = $LevelUpMenu
@onready
var level_up_menu_container: Control = $LevelUpMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer
@onready
var upgrade_button_group: ButtonGroup = $LevelUpMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/OptionOne.button_group
@onready
var level_up_time_limit: RadialProgress = $LevelUpMenu/SelectionTimeLimit
@onready
var upgrade_confirm_button: Button = $LevelUpMenu/PanelContainer/MarginContainer/VBoxContainer/ConfirmButton
var selected_button: Button

@onready
var minimap: Minimap = $Minimap

@onready
var health_icon: PackedScene = preload("res://Scenes/Interface/health_icon.tscn")
@onready
var left_bullet_info_menu_container: Container = $ExperienceBar/LeftBulletInfoMenu/MarginContainer/GridContainer
@onready
var right_bullet_info_menu_container: Container = $ExperienceBar/RightBulletInfoMenu/MarginContainer/GridContainer
@onready
var bullet_generation_info: Control = $BulletGenerationInfoMenu

## Active reload ui
@onready
var weapon_one_active_reload: Control = $ExperienceBar/WeaponOneActiveReloadBar
@onready
var weapon_two_active_reload: Control = $ExperienceBar/WeaponTwoActiveReloadBar

@onready
var score_info_ui: Control = $HealthScoreContainer/ScoreInfo

@onready
var upgrade_ui: UpgradeUI = $UpgradeUI

@onready
var enemy_spawn_info: Control = $EnemySpawnInfo

@onready
var mutation_roulette: Roulette = $MutationRoulette

@onready
var vignette_overlay: TextureRect = $VignetteOverlay

var upgrade_timer: Timer

@onready
var buff_icon_container: BuffIconContainer = $HealthScoreContainer/ScoreInfo/BuffIconContainer


func _ready():
	item_info.visible = false
	
	upgrade_options = level_up_menu_container.get_children()
	for button in upgrade_options:
		pass
	upgrade_confirm_button.pressed.connect(upgrade_option_selected)
	
	level_up_menu.visible = false
	
	mutation_roulette.option_selected.connect(show_mutation_info)
	
	vignette_overlay.visible = true
	
	for i in inventory_slots.get_child_count():
		inventory_slots.get_child(i).get_node("ShortcutLabel").text = str(i + 1)

func _process(_delta: float) -> void:
	## player level up selection time limit
	if !upgrade_timer.is_stopped():
		level_up_time_limit.progress = (1 - (upgrade_timer.time_left / upgrade_timer.wait_time)) * 100
		
func show_item_info(item: ItemData):
	#item_info.visible = true
	item_info.get_node("AnimationPlayer").play("RESET")
	var item_icon: TextureRect = item_info.get_node("MarginContainer/HBoxContainer/ItemIcon")
	if item.icon != null:
		item_icon.texture = item.icon
		item_icon.self_modulate = Color.WHITE
	else:
		item_icon.texture = item.default_icon
		
	#item_icon.self_modulate = item.color
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
	if item.icon == null:
		item_icon.texture = item.default_icon
		
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
	
	# press one button by default
	upgrade_options[1].button_pressed = true
	upgrade_options[1]._on_toggled(true)
	
	level_up_menu.visible = true
	$LevelUpMenu/AnimationPlayer.play("show_level_up_menu")

func upgrade_option_selected() -> void:
	upgrade_timer.stop()
	get_tree().paused = false
	level_up_menu.visible = false

func update_bullet_menu(weapon_one = InputManager.selected_unit.weapon_one, weapon_two = InputManager.selected_unit.weapon_two) -> void:
	DW_ToolBox.RemoveAllChildren(left_bullet_info_menu_container)
	DW_ToolBox.RemoveAllChildren(right_bullet_info_menu_container)
	
	var bullets = weapon_one.bullets
		
	for i in range(bullets.size()):
		#var new_icon: TextureRect = health_icon.instantiate()
		#new_icon.custom_minimum_size = Vector2(16,16)
		var new_label: RichTextLabel = RichTextLabel.new()
		new_label.fit_content = true
		new_label.scroll_active = false
		new_label.bbcode_enabled = true
		new_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i == 0:
			new_label.self_modulate = Color.GREEN
		new_label.add_theme_font_size_override("font_size", 12)
		if i < weapon_one.get_queued_attack_count():
			new_label.self_modulate = Color.YELLOW
		new_label.text = "[right]" + str(bullets[i]) + "[/right]"
		left_bullet_info_menu_container.add_child(new_label)
		
	bullets = []
	bullets = weapon_two.bullets
		
	for i in range(bullets.size()):
		#var new_icon: TextureRect = health_icon.instantiate()
		#new_icon.custom_minimum_size = Vector2(16,16)
		var new_label: RichTextLabel = RichTextLabel.new()
		new_label.fit_content = true
		new_label.scroll_active = false
		new_label.bbcode_enabled = true
		new_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i == 0:
			new_label.self_modulate = Color.GREEN
		new_label.add_theme_font_size_override("font_size", 12)
		if i < weapon_two.get_queued_attack_count():
			new_label.self_modulate = Color.YELLOW
		new_label.text = str(bullets[i])
		right_bullet_info_menu_container.add_child(new_label)

#func update_bullet_generation_info_menu(component = InputManager.selected_unit.bullet_generator_component) -> void:
	#var labels_label: Label = bullet_generation_info.get_node("MarginContainer/Labels")
	#var values_label: Label = bullet_generation_info.get_node("MarginContainer/Values")
	#
	#var gun: BulletGenerator = component
	
	#labels_label.text = "Enchant Chance:\n\n"
	#values_label.text = str(int(gun.trait_chance * 100)) + "%\n"
	#
	#labels_label.text += "Active Enchants:\n"
	
	#labels_label.text += gun.print_traits()
	
	return
	
	#if gun.piercing_chance > 0:
		#labels_label.text += "Piercing\n"
	#if gun.explosive_chance > 0:
		#labels_label.text += "Explosive\n"
	#if gun.buckshot_chance > 0:
		#labels_label.text += "Buckshot\n"
	#if gun.quickshot_chance > 0:
		#labels_label.text += "Quickshot\n"
	#if gun.fire_chance > 0:
		#labels_label.text += "Fire\n"
	#if gun.vampire > 0:
		#labels_label.text += "Vampire\n"

func update_enemy_spawn_info(_spawner: EnemySpawnerComponent) -> void:
	# disabled for now
	return
	
	#var labels_label: Label = enemy_spawn_info.get_node("MarginContainer/Labels")
	#var values_label: Label = enemy_spawn_info.get_node("MarginContainer/Values")
	#
	#labels_label.text = "Spawn Rate:\n"
	#values_label.text = str(DW_ToolBox.TrimDecimalPoints(1/spawner.spawn_cooldown, 1)) + " per second\n"
	#labels_label.text += "Wave(x" + str(spawner.wave_count) + ")" + " Chance:\n"
	#values_label.text += str(int(spawner.wave_chance * 1000)/10.0) + "%\n"
	#labels_label.text += "HP Range:\n"
	#values_label.text += str(spawner.health_range.x) + " - " + str(spawner.health_range.y) + "\n"
	#labels_label.text += "Speed Range:\n"
	#values_label.text += str(spawner.move_speed_range.x) + " - " + str(spawner.move_speed_range.y) + "\n"
	#if spawner.heavy_chance != 0:
		#labels_label.text += "Heavy:\n"
		#values_label.text += str(int(spawner.heavy_chance*1000)/10.0) + "%\n"
	#if spawner.fast_chance != 0:
		#labels_label.text += "Fast:\n"
		#values_label.text += str(int(spawner.fast_chance*1000)/10.0) + "%\n"
	#if spawner.ranged_chance != 0:
		#labels_label.text += "Ranged:\n"
		#values_label.text += str(int(spawner.ranged_chance*1000)/10.0) + "%\n"
	#if spawner.shield_chance != 0:
		#labels_label.text += "Shield:\n"
		#values_label.text += str(int(spawner.shield_chance*1000)/10.0) + "%\n"

#func make_exp_popup(amount: int) -> void:
	#var new_popup = exp_popup.instantiate()
	#new_popup.get_node("Label").text = "+" + str(amount)
	#experience_bar.add_child(new_popup)

func update_reload_marker(node, weapon):
	var marker: Control = node.get_node("TextureRect")
	## Set active reload marker size
	var ratio: float = InputManager.selected_unit.weapon_one.active_reload_length / 100.0
	marker.size.y = weapon_one_active_reload.size.y * ratio
	
	var mid_point: float = (weapon.active_reload_range.x + weapon.active_reload_range.y) / 2.0
	# set marker position
	marker.position.y = weapon_one_active_reload.size.y * (1 - mid_point/100.0) - marker.size.y / 2
	
	#print("mid point: " + str(mid_point))
	
func show_vignette_effect(duration: float, color: Color) -> void:
	var tween: Tween = get_tree().create_tween()
	vignette_overlay.self_modulate = color
	tween.tween_property(vignette_overlay, "self_modulate", Color(color, 0), duration)

func update_inventory_slots(inventory) -> void:
	for i: int in range(inventory.size()):
		var new_slot: Control
		if i < inventory_slots.get_child_count():
			new_slot = inventory_slots.get_child(i)
		else:
			new_slot = item_slot.instantiate()
			inventory_slots.add_child(new_slot)
			
		new_slot.get_node("ShortcutLabel").text = str(i + 1)
		new_slot.get_node("ItemIcon").texture = inventory[i].icon
	
	for i: int in range(inventory_slots.get_child_count()):
		if i >= inventory.size():
			if i > 4:
				inventory_slots.get_child(i).visible = false
			else:
				inventory_slots.get_child(i).get_node("ItemIcon").texture = null

func select_inventory_slot(index: int) -> void:
	if index < inventory_slots.get_child_count():
		inventory_slots.get_child(index).get_node("TextureButton").button_pressed = true
