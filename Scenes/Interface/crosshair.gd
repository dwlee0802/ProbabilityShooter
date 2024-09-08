extends Node2D

@onready
var info_label: Label = $InfoLabel
@onready
var mag_label: Label = $MagazineLabel
@onready
var image: RadialProgress = $RadialProgress
@onready
var selected_unit_pointer: Node2D = $SelectedUnitPointer

@onready
var active_reload_component: ActiveReloadComponent = $ActiveReloadComponent


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !InputManager.selected_unit.reload_started.is_connected(active_reload_component.update_reload_marker):
		InputManager.selected_unit.reload_started.connect(active_reload_component.update_reload_marker)
		
	global_position = get_global_mouse_position()
	
	# depending on attack available, change infolabel content
	if InputManager.selected_unit != null:
		# show damage range
		image.progress = 100
		var current_eq: Equipment = InputManager.selected_unit.get_current_equipment()
		if current_eq is Gun and current_eq.bullets.size() > 0:
			var num: int = InputManager.selected_unit.get_queued_attack_count()
			if num >= current_eq.bullets.size():
				info_label.text = ""
			else:
				info_label.text = str(int(current_eq.bullets[num].damage_amount * (1 + InputManager.selected_unit.charge/100)))
		else:
			info_label.text = ""
		
		# reloading
		if !current_eq.ready:
			var timer: Timer = InputManager.selected_unit.get_current_equipment_timer()
			#info_label.text = str(int(InputManager.selected_unit.action_one_reload_timer.time_left * 10)/10.0)
			image.progress = int((timer.wait_time - timer.time_left) / (timer.wait_time) * 100)
			if InputManager.selected_unit.active_reload_available:
				image.bar_color = Color.YELLOW
			else:
				image.bar_color = Color.ORANGE_RED
				
			if current_eq is Gun:
				mag_label.text = str(DW_ToolBox.TrimDecimalPoints(timer.time_left, 2))
		else:
			image.bar_color = Color.GREEN
			if current_eq is Gun:
				mag_label.text = InputManager.selected_unit.get_magazine_status()
			else:
				mag_label.text = "0/0"
