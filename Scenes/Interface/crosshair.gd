extends Node2D

@onready
var weapon_one_ui: Control = $WeaponOne
@onready
var weapon_one_active_reload_bar: ProgressBar = $WeaponOne/ActiveReloadBar

@onready
var weapon_two_ui: Control = $WeaponTwo
@onready
var weapon_two_active_reload_bar: ProgressBar = $WeaponTwo/ActiveReloadBar

@onready
var active_reload_component: ActiveReloadComponent = $ActiveReloadComponent

@onready
var reload_finished_animation: AnimationPlayer = $Control/ReloadFinishedEffect/AnimationPlayer

@onready
var click_animation: AnimationPlayer = $Control/AnimationPlayer

var player_unit: PlayerUnit

func _ready() -> void:
	player_unit = InputManager.selected_unit

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
	
	if !player_unit.weapon_one.weapon.have_bullets():
		update_active_reload_bar(weapon_one_active_reload_bar, player_unit.weapon_one)
	if !player_unit.weapon_two.weapon.have_bullets():
		update_active_reload_bar(weapon_two_active_reload_bar, player_unit.weapon_two)
		
func update_weapon_info_label(weapon_ui, weapon: WeaponComponent) -> void:
	if weapon == null:
		return
		
	# show damage range
	var current_eq: Equipment = weapon.weapon
	
	var mag_label: Label = weapon_ui.get_node("VBoxContainer/MagazineLabel")
	var mag_container: HBoxContainer = weapon_ui.get_node("VBoxContainer/MagazineContainer")
	var dmg_label: Label = weapon_ui.get_node("VBoxContainer/DamageLabel")
	var traits_label: Label = weapon_ui.get_node("VBoxContainer/TraitsLabel")
	
	var active_reload_bar: Control = weapon_ui.get_node("ActiveReloadBar")
	
	mag_label.add_theme_color_override("font_outline_color", weapon.weapon_color)
	dmg_label.add_theme_color_override("font_outline_color", weapon.weapon_color)
	
	if current_eq.have_bullets():
		mag_container.visible = true
		active_reload_bar.visible = false
		var queued_count: int = weapon.get_queued_attack_count()
		var unused_bullet_count = current_eq.bullets.size() - queued_count
		
		for i: int in mag_container.get_child_count():
			#mag_container.get_child(i).visible = i < current_eq.bullets.size() - queued_count
			if i < unused_bullet_count:
				mag_container.get_child(i).self_modulate = weapon.weapon_color
			else:
				mag_container.get_child(i).self_modulate = weapon.weapon_color.darkened(0.8)
				
		if unused_bullet_count > 0:
			# dmg label
			dmg_label.text = current_eq.bullets[queued_count].to_string_crosshair(true)
				
			# traits label
			traits_label.text = current_eq.bullets[queued_count].print_traits()
		else:
			dmg_label.text = ""
			traits_label.text = ""
	else:
		#var timer: Timer = weapon.reload_timer
		#mag_label.text = str(DW_ToolBox.TrimDecimalPoints(timer.time_left, 2))
		dmg_label.text = ""
		traits_label.text = ""
		active_reload_bar.visible = true
		
		# make marker and mag label light up when inside range
		
		if weapon.active_reload_failed:
			active_reload_bar.self_modulate = weapon.weapon_color.darkened(0.5)
		else:
			active_reload_bar.self_modulate = weapon.weapon_color

func update_active_reload_bar(bar: ProgressBar, weapon: WeaponComponent) -> void:
	bar.value = int((weapon.reload_timer.wait_time - weapon.reload_timer.time_left) / (weapon.reload_timer.wait_time) * 100)
	
	# show indicator if inside success range
	var highlight: ColorRect = bar.get_node("ColorRect")
	if !highlight.visible:
		if weapon.inside_active_reload_range():
			highlight.visible = true
	else:
		if !weapon.inside_active_reload_range():
			highlight.visible = false
