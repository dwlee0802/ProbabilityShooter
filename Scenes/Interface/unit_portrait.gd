extends Control
class_name UnitPortrait

@onready
var shortcut_label: Label = $PanelContainer/Image/ShortCutLabel
@onready
var animation_player: AnimationPlayer = $AnimationPlayer

var target_unit: PlayerUnit

@onready
var health_bar: DelayedProgressBar = $PanelContainer/HealthBar

@onready
var cooldown_shadow: Control = $PanelContainer/WeaponImage/CooldownShadow
@onready
var reload_complete_animation_player: AnimationPlayer = $PanelContainer/WeaponImage/ReadyTint/AnimationPlayer

@onready
var secondary_cooldown_shade: Control = $PanelContainer/SkillIcons/TextureRect/CooldownShadow
@onready
var secondary_reload_animation: AnimationPlayer = $PanelContainer/SkillIcons/TextureRect/ReadyTint/AnimationPlayer


func set_shortcut_label(num: int) -> void:
	shortcut_label.text = str(num)

func set_unit(unit: PlayerUnit) -> void:
	target_unit = unit
	visible = target_unit != null
	if !visible:
		return
	
	health_bar.set_max(target_unit.max_health_points)
	update_healthbar()
	
	# set portrait image
	
	# connect signals
	target_unit.was_selected.connect(animation_player.play.bind("portrait_select"))
	target_unit.deselected.connect(animation_player.play.bind("RESET"))
	target_unit.health_changed.connect(update_healthbar)
	target_unit.action_one_reload_timer.timeout.connect(reload_complete_animation_player.play.bind("reload_finished_animation"))
	target_unit.was_attacked.connect($PanelContainer/Image/HitShadow/AnimationPlayer.play.bind("hit_portrait_animation"))
	target_unit.knocked_out.connect(on_unit_knocked_out)
	target_unit.revived.connect(on_unit_revived)
	target_unit.equipment_changed.connect(on_unit_equipment_changed)
	on_unit_equipment_changed()

func update_healthbar():
	health_bar.change_value(target_unit.health_points)

func on_unit_knocked_out():
	$PanelContainer/Image/UnconsciousShadow.visible = true
func on_unit_revived():
	$PanelContainer/Image/UnconsciousShadow.visible = false
	health_bar.change_value(target_unit.health_points)
	
func _process(_delta):
	if target_unit != null:
		if !target_unit.action_one_reload_timer.is_stopped():
			cooldown_shadow.anchor_bottom = (target_unit.action_one_reload_timer.time_left / target_unit.get_current_equipment().data.reload_time)
			
		# do it for the other equipment too
		if !target_unit.secondary_reload_timer.is_stopped():
			if target_unit.has_secondary():
				secondary_cooldown_shade.anchor_bottom = (target_unit.secondary_reload_timer.time_left / target_unit.equipments[1].data.reload_time)
			
			
func on_unit_equipment_changed() -> void:
	if target_unit == null:
		return
		
	var current_equipment: Equipment = target_unit.get_current_equipment()
	var other_equipment: Equipment
	if target_unit.has_secondary():
		other_equipment = target_unit.get_other_equipment()
	
	$PanelContainer/SkillIcons/TextureRect.visible = other_equipment != null
	
	# set cooldown shades
	if !current_equipment.ready:
		cooldown_shadow.anchor_bottom = (target_unit.get_current_equipment_timer().time_left / current_equipment.data.reload_time)
	else:
		cooldown_shadow.anchor_bottom = 0
		
	if other_equipment != null and !other_equipment.ready:
		secondary_cooldown_shade.anchor_bottom = (target_unit.get_other_equipment_timer().time_left / other_equipment.data.reload_time)
	else:
		secondary_cooldown_shade.anchor_bottom = 0
	
	if other_equipment != null:
		update_equipment_name_label(current_equipment.data.equipment_name, other_equipment.data.equipment_name)
	else:
		update_equipment_name_label(current_equipment.data.equipment_name, "")
		
func update_equipment_name_label(main_name: String, other_name: String) -> void:
	# update name label
	$PanelContainer/SkillIcons/TextureRect/WeaponNameLabel.text = other_name
	$PanelContainer/WeaponImage/ReadyTint/WeaponNameLabel.text = main_name
	
