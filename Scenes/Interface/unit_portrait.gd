extends Control
class_name UnitPortrait

var portrait_image: TextureRect
@onready
var shortcut_label: Label = $PortraitImage/ShortCutLabel
@onready
var animation_player: AnimationPlayer = $AnimationPlayer

var target_unit: PlayerUnit

@onready
var health_bar: DelayedProgressBar = $PortraitImage/HealthBar
@onready
var hit_animation: AnimationPlayer = $PortraitImage/HitShadow/AnimationPlayer

@onready
var main_slot: Control = $VBoxContainer/CurrentSlot
@onready
var secondary_slot: Control = $VBoxContainer/OtherSlot
@onready
var main_equipment_icon: EquipmentIcon = $VBoxContainer/CurrentSlot/MainWeaponIcon
@onready
var secondary_equipment_icon: EquipmentIcon = $VBoxContainer/OtherSlot/SecondaryWeaponIcon

func _ready() -> void:
	portrait_image = $PortraitImage
	
func set_shortcut_label(num: int) -> void:
	shortcut_label.text = str(num)

func set_unit(unit: PlayerUnit) -> void:
	target_unit = unit
	visible = target_unit != null
	if !visible:
		return
	
	portrait_image.self_modulate = target_unit.temp_color
	
	health_bar.set_max(target_unit.max_health_points)
	update_healthbar()
	
	# set equipment icon data
	main_equipment_icon.set_data(target_unit.equipments[0], target_unit.action_one_reload_timer)
	if target_unit.has_secondary():
		secondary_equipment_icon.set_data(target_unit.equipments[1], target_unit.secondary_reload_timer)
	else:
		secondary_equipment_icon.visible = false
	
	# connect signals
	target_unit.was_selected.connect(animation_player.play.bind("portrait_select"))
	target_unit.deselected.connect(animation_player.play.bind("RESET"))
	target_unit.health_changed.connect(update_healthbar)
	target_unit.was_attacked.connect(hit_animation.play.bind("hit_portrait_animation"))
	target_unit.knocked_out.connect(on_unit_knocked_out)
	target_unit.revived.connect(on_unit_revived)
	target_unit.equipment_changed.connect(on_unit_equipment_changed)

func update_healthbar():
	health_bar.change_value(target_unit.health_points)

func on_unit_knocked_out():
	$PortraitImage/UnconsciousShadow.visible = true
func on_unit_revived():
	$PortraitImage/UnconsciousShadow.visible = false
	health_bar.change_value(target_unit.health_points)
	
func _process(_delta):
	pass
			
func on_unit_equipment_changed() -> void:
	if target_unit == null:
		return
	if !target_unit.has_secondary():
		return
	
	# remove children
	for child in main_slot.get_children():
		main_slot.remove_child(child)
	for child in secondary_slot.get_children():
		secondary_slot.remove_child(child)
		
	## equipped main equipment
	if target_unit.get_current_equipment() == main_equipment_icon.target_equipment:
		main_slot.add_child(main_equipment_icon)
		secondary_slot.add_child(secondary_equipment_icon)
	## equipped secondary
	else:
		main_slot.add_child(secondary_equipment_icon)
		secondary_slot.add_child(main_equipment_icon)
	
func update_equipment_name_label(main_name: String, other_name: String) -> void:
	# update name label
	$PanelContainer/SkillIcons/TextureRect/WeaponNameLabel.text = other_name
	$PanelContainer/WeaponImage/ReadyTint/WeaponNameLabel.text = main_name
	
