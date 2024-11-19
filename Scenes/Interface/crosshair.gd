extends Node2D

var mag_bullet_icon: PackedScene = preload("res://Scenes/Interface/mag_bullet_icon.tscn")

@onready
var weapon_one_ui: Control = $WeaponOne
@onready
var weapon_one_active_reload_bar: ProgressBar = $WeaponOne/ActiveReloadBar

@onready
var weapon_two_ui: Control = $WeaponTwo
@onready
var weapon_two_active_reload_bar: ProgressBar = $WeaponTwo/ActiveReloadBar

@onready
var melee_ui: Control = $MeleeWeapon
@onready
var light_attack_cooldown: ProgressBar = $MeleeWeapon/LightAttackCooldown
@onready
var heavy_attack_cooldown: ProgressBar = $MeleeWeapon/HeavyAttackCooldown

@onready
var active_reload_component: ActiveReloadComponent = $ActiveReloadComponent

@onready
var reload_finished_animation: AnimationPlayer = $Control/ReloadFinishedEffect/AnimationPlayer

@onready
var click_animation: AnimationPlayer = $Control/AnimationPlayer

var player_unit: PlayerUnit

var first_frame: bool = true


func _ready() -> void:
	player_unit = InputManager.selected_unit
	_input(null)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_animation.play("click_effect")
	
	if player_unit != null:
		update_weapon_info_label(weapon_one_ui, player_unit.weapon_one)
		update_weapon_info_label(weapon_two_ui, player_unit.weapon_two)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	
	player_unit = InputManager.selected_unit
	if player_unit == null or player_unit.is_unconscious():
		return
		
	if !player_unit.weapon_changed.is_connected(on_player_weapon_changed):
		player_unit.weapon_changed.connect(on_player_weapon_changed)
		on_player_weapon_changed()
		
	if first_frame:
		update_weapon_info_label(weapon_one_ui, player_unit.weapon_one)
		update_weapon_info_label(weapon_two_ui, player_unit.weapon_two)
		set_magazine_max_count(weapon_one_ui, player_unit.weapon_one.magazine_size)
		set_magazine_max_count(weapon_two_ui, player_unit.weapon_two.magazine_size)
		first_frame = false
		
	if player_unit.weapon_one != null:
		if !player_unit.weapon_one.reload_started.is_connected(active_reload_component.update_reload_marker):
			player_unit.weapon_one.reload_started.connect(active_reload_component.update_reload_marker.bind(weapon_one_ui.get_node("ActiveReloadBar"), player_unit.weapon_one))
		if !player_unit.weapon_one.reload_complete.is_connected(reload_finished_animation.play.bind("reload_finished")):
			player_unit.weapon_one.reload_complete.connect(reload_finished_animation.play.bind("reload_finished"))
	
	if player_unit.weapon_two != null:
		if !player_unit.weapon_two.reload_started.is_connected(active_reload_component.update_reload_marker):
			player_unit.weapon_two.reload_started.connect(active_reload_component.update_reload_marker.bind(weapon_two_ui.get_node("ActiveReloadBar"), player_unit.weapon_two))
		if !player_unit.weapon_two.reload_complete.is_connected(reload_finished_animation.play.bind("reload_finished")):
			player_unit.weapon_two.reload_complete.connect(reload_finished_animation.play.bind("reload_finished"))
	
	if player_unit.selected_weapon == PlayerUnit.WeaponType.MELEE:
		update_melee_cooldown(heavy_attack_cooldown, player_unit.melee_weapon.heavy_attack_cooldown_timer)
		update_melee_cooldown(light_attack_cooldown, player_unit.melee_weapon.light_attack_cooldown_timer)
		
	if !player_unit.weapon_one.has_bullets():
		update_active_reload_bar(weapon_one_active_reload_bar, player_unit.weapon_one)
	if !player_unit.weapon_two.has_bullets():
		update_active_reload_bar(weapon_two_active_reload_bar, player_unit.weapon_two)
		
func update_weapon_info_label(weapon_ui, weapon: WeaponComponent) -> void:
	if weapon == null:
		return
		
	var mag_label: Label = weapon_ui.get_node("VBoxContainer/MagazineLabel")
	var mag_container: HBoxContainer = weapon_ui.get_node("VBoxContainer/MagazineContainer")
	var health_hearts: HealthHearts = weapon_ui.get_node("VBoxContainer/HealthHearts")
	var traits_label: Label = weapon_ui.get_node("VBoxContainer/TraitsLabel")
	
	var active_reload_bar: Control = weapon_ui.get_node("ActiveReloadBar")
	
	mag_label.add_theme_color_override("font_outline_color", weapon.weapon_color)
	
	if !weapon.magazine_empty():
		mag_container.visible = true
		active_reload_bar.visible = false
		var unused_bullet_count = weapon.bullets.size()
		var _queued_bullet_count = weapon.queued_bullets.size()
		
		for i: int in mag_container.get_child_count():
			#mag_container.get_child(i).visible = i < current_eq.bullets.size() - queued_count
			if i < unused_bullet_count:
				# available bullet
				mag_container.get_child(i).self_modulate = weapon.weapon_color
			else:
				mag_container.get_child(i).self_modulate = weapon.weapon_color.darkened(0.8)
				
		if unused_bullet_count > 0:
			## dmg label
			#health_hearts.set_hearts_count(weapon.bullets[queued_count].damage_amount, Vector2(16,16))
				#
			# traits label
			traits_label.text = weapon.bullets.front().print_traits()
			pass
		else:
			health_hearts.set_hearts_count(0, Vector2(16,16))
			traits_label.text = ""
	else:
		#var timer: Timer = weapon.reload_timer
		#mag_label.text = str(DW_ToolBox.TrimDecimalPoints(timer.time_left, 2))
		health_hearts.set_hearts_count(0, Vector2(16,16))
		traits_label.text = ""
		active_reload_bar.visible = true
		
		# make marker and mag label light up when inside range
		
		if weapon.active_reload_failed:
			active_reload_bar.self_modulate = weapon.weapon_color.darkened(0.5)
		else:
			active_reload_bar.self_modulate = weapon.weapon_color

func update_active_reload_bar(bar: ProgressBar, weapon: WeaponComponent) -> void:
	bar.value = int((weapon.reload_timer.max_time - weapon.reload_timer.time_left) / (weapon.reload_timer.max_time) * 100)
	
	# show indicator if inside success range
	var highlight: ColorRect = bar.get_node("ColorRect")
	if !highlight.visible:
		if weapon.inside_active_reload_range() >= WeaponComponent.ActiveReloadResult.GOOD:
			highlight.visible = true
	else:
		if !weapon.inside_active_reload_range():
			highlight.visible = false

func update_melee_cooldown(bar: ProgressBar, timer: Timer) -> void:
	#if timer.is_stopped():
		#if bar.visible:
			#bar.visible = false
		#return
	#if !bar.visible:
		#bar.visible = true
	bar.value = (timer.wait_time - timer.time_left)/timer.wait_time * 100
	
func set_magazine_max_count(weapon_ui, count: int) -> void:
	var mag_container: HBoxContainer = weapon_ui.get_node("VBoxContainer/MagazineContainer")
	DW_ToolBox.RemoveAllChildren(mag_container)
	for i in range(count):
		mag_container.add_child(mag_bullet_icon.instantiate())

func on_player_weapon_changed() -> void:
	if !player_unit:
		return
	
	melee_ui.visible = false
	weapon_one_ui.visible = false
	weapon_two_ui.visible = false
	
	if player_unit.selected_weapon == PlayerUnit.WeaponType.MELEE:
		melee_ui.visible = true
	if player_unit.selected_weapon == PlayerUnit.WeaponType.DEFAULT:
		weapon_one_ui.visible = true
		weapon_two_ui.visible = true
