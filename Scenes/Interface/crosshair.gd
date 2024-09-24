extends Node2D

@onready
var weapon_one_ui: Control = $WeaponOne
@onready
var weapon_two_ui: Control = $WeaponTwo

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
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	player_unit = InputManager.selected_unit
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
		
	global_position = get_global_mouse_position()
	update_weapon_info_label(weapon_one_ui, player_unit.weapon_one)
	update_weapon_info_label(weapon_two_ui, player_unit.weapon_two)

func update_weapon_info_label(weapon_ui, weapon) -> void:
	# show damage range
	var current_eq: Equipment = weapon.weapon
	
	var bullet_info_label: RichTextLabel = weapon_ui.get_node("InfoLabel")
	var active_reload_ui: ProgressBar = weapon_ui.get_node("ActiveReloadBar")
	var mag_label: Label = weapon_ui.get_node("MagazineLabel")
	
	if current_eq is Gun and current_eq.bullets.size() > 0:
		var queued_count: int = weapon.get_queued_attack_count()
		# queued all bullets. nothing to show
		if queued_count >= current_eq.bullets.size():
			bullet_info_label.text = ""
		else:
			# show next bullet info
			bullet_info_label.text = str(current_eq.bullets[queued_count])
	else:
		bullet_info_label.text = ""
	
	# reloading
	if !current_eq.have_bullets():
		active_reload_ui.visible = true
		var timer: Timer = weapon.reload_timer
		active_reload_ui.value = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
		if weapon.active_reload_available:
			active_reload_ui.self_modulate = Color.YELLOW
		else:
			if weapon.active_reload_failed:
				active_reload_ui.self_modulate = Color.RED
			else:
				active_reload_ui.self_modulate = Color.GREEN
				#image.progress = 100
			
		if current_eq is Gun:
			mag_label.text = str(DW_ToolBox.TrimDecimalPoints(timer.time_left, 2))
	else:
		active_reload_ui.visible = false
		if current_eq is Gun:
			mag_label.text = weapon.get_magazine_status()
		else:
			mag_label.text = "0/0"
