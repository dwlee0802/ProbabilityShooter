extends Node2D

@onready
var right_info_label: RichTextLabel = $Rightside/InfoLabel
@onready
var left_info_label: RichTextLabel = $Leftside/InfoLabel

@onready
var right_mag_label: Label = $Rightside/MagazineLabel
@onready
var left_mag_label: Label = $Leftside/MagazineLabel

@onready
var image: RadialProgress = $Control/RadialProgress

@onready
var active_reload_component: ActiveReloadComponent = $ActiveReloadComponent

@onready
var reload_finished_animation: AnimationPlayer = $Control/ReloadFinishedEffect/AnimationPlayer

@onready
var click_animation: AnimationPlayer = $Control/AnimationPlayer

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_animation.play("click_effect")
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !InputManager.selected_unit.weapon_one.reload_started.is_connected(active_reload_component.update_reload_marker):
		InputManager.selected_unit.weapon_one.reload_started.connect(active_reload_component.update_reload_marker)
	if !InputManager.selected_unit.weapon_one.reload_complete.is_connected(reload_finished_animation.play.bind("reload_finished")):
		InputManager.selected_unit.weapon_one.reload_complete.connect(reload_finished_animation.play.bind("reload_finished"))
		
	global_position = get_global_mouse_position()
	
	# depending on attack available, change infolabel content
	if InputManager.selected_unit != null:
		# show damage range
		image.progress = 100
		var current_eq: Equipment = InputManager.selected_unit.weapon_one.weapon
		if current_eq is Gun and current_eq.bullets.size() > 0:
			var num: int = InputManager.selected_unit.weapon_one.get_queued_attack_count()
			if num >= current_eq.bullets.size():
				left_info_label.text = ""
			else:
				left_info_label.text = str(current_eq.bullets[num])
		else:
			left_info_label.text = ""
		
		# reloading
		if !current_eq.have_bullets():
			var timer: Timer = InputManager.selected_unit.weapon_one.reload_timer
			image.progress = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
			if InputManager.selected_unit.weapon_one.active_reload_available:
				image.bar_color = Color.YELLOW
			else:
				if InputManager.selected_unit.active_reload_failed:
					image.bar_color = Color.ORANGE_RED
				else:
					image.bar_color = Color.GREEN
					#image.progress = 100
				
			if current_eq is Gun:
				left_mag_label.text = str(DW_ToolBox.TrimDecimalPoints(timer.time_left, 2))
		else:
			image.bar_color = Color.GREEN
			if current_eq is Gun:
				left_mag_label.text = InputManager.selected_unit.get_magazine_status()
			else:
				left_mag_label.text = "0/0"

	# weapon two
	if InputManager.selected_unit != null:
		# show damage range
		image.progress = 100
		var current_eq: Equipment = InputManager.selected_unit.weapon_two.weapon
		if current_eq is Gun and current_eq.bullets.size() > 0:
			var num: int = InputManager.selected_unit.weapon_two.get_queued_attack_count()
			if num >= current_eq.bullets.size():
				right_info_label.text = ""
			else:
				right_info_label.text = str(current_eq.bullets[num])
		else:
			right_info_label.text = ""
		
		if InputManager.selected_unit.weapon_two != null:
			# reloading
			if !current_eq.have_bullets():
				var timer: Timer = InputManager.selected_unit.weapon_two.reload_timer
				image.progress = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
				if InputManager.selected_unit.weapon_two.active_reload_available:
					image.bar_color = Color.YELLOW
				else:
					if InputManager.selected_unit.active_reload_failed:
						image.bar_color = Color.ORANGE_RED
					else:
						image.bar_color = Color.GREEN
						#image.progress = 100
					
				if current_eq is Gun:
					right_mag_label.text = str(DW_ToolBox.TrimDecimalPoints(timer.time_left, 2))
			else:
				image.bar_color = Color.GREEN
				if current_eq is Gun:
					right_mag_label.text = InputManager.selected_unit.get_magazine_status(false)
				else:
					right_mag_label.text = "0/0"
