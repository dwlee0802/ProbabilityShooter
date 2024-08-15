extends Unit
class_name PlayerUnit

@onready
var state_label: Label = $StateLabel
@onready
var state_machine: StateMachine = $StateMachine

@onready
var shortcut_label: Label = $ShortcutLabel

#region Unit Stat Variables
@export_category("Unit Stats")
@export
var movement_speed: float = 100
var movement_speed_bonus: float = 0
var movement_speed_multiplier: float = 1.0
@export
var temp_color: Color = Color.WHITE
var damage_bonus: Vector2i = Vector2i(0, 0)
@export
var health_points: float = 500
@export
var max_health_points: int = 500
@onready
var health_bar: DelayedProgressBar = $HealthBar
@onready
var revive_time: float = 5.0
var aim_speed_modifier: float = 0
var reload_speed_modifier: float = 0
#endregion

@onready
var effects: Node = $Effects

#region Equipment Variables
@export_category("Equipment")
@export
var current_equipped_index: int = 0
@export
var equipments = []
@export
var starting_equipments = []
## dictionary<ItemData data, int level> to store items this unit got
var items = {}
@export
var starting_item: ItemData = null
#endregion

@onready
var action_one_reload_timer: Timer = $ActionOneReloadTimer

@export_category("Aim Line")
@export
#region Aim UI settings
var aim_color: Color = Color.DIM_GRAY
@export
var attack_color: Color = Color.RED
@export
var queued_color: Color = Color.ORANGE
@export
var background_color: Color = Color.BLACK

@onready
var arm: Node2D = $Arm
@onready
var aim_line: Line2D = $AimLine
@onready
var attack_line: Line2D = $AttackLine
@onready
var attack_cone: Polygon2D = $AttackFullCone/AttackCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone
@onready
var aim_cone: Polygon2D = $AimCone
@onready
var queued_cones: Node2D = $QueuedCones
@onready
var attack_line_anim: AnimationPlayer = $AttackLine/AnimationPlayer
@onready
var move_line: Line2D = $MoveLine
#endregion

## interaction
@onready
var interaction_area: Area2D = $InteractionArea

## sound
@onready var gunshot_sfx: AudioStreamPlayer2D = $GunshotSoundPlayer
@onready var reload_sfx: AudioStreamPlayer2D = $ReloadSoundPlayer

#region Experience System
var experience_gained: int = 0
var current_level: int = 1
#endregion

#region Signals
signal was_selected
signal deselected
signal health_changed
signal was_attacked
signal knocked_out
signal revived
signal equipment_changed
signal picked_up_item(item)
signal experience_changed
signal level_increased
#endregion


func _ready() -> void:
	# instantiate gun objects
	for eq: EquipmentData in starting_equipments:
		if eq is RayGunData:
			equipments.append(RayGun.new(eq))
		elif eq is GrenadeData:
			equipments.append(Grenade.new(eq))
		elif eq is EffectorData:
			equipments.append(Effector.new(eq))
		else:
			equipments.append(Gun.new(eq))
	
	$ActionOneReloadTimer.timeout.connect(reload_action)
	equipment_changed.connect($ActionOneReloadTimer.stop)
	equipment_changed.connect(update_aim_cone)
	update_aim_cone()
	print("equipped " + get_current_equipment().data.equipment_name)
	
	aim_line.default_color = aim_color
	attack_line.default_color = attack_color
	# cone colors
	aim_cone.color = aim_color
	attack_cone.color = attack_color
	attack_full_cone.color = background_color
	
	state_machine.init(self)
	$Sprite2D.self_modulate = temp_color
	
	# unit health
	health_points = int(max_health_points)
	health_bar.set_max(max_health_points)
	health_bar.change_value(health_points)
	
	if get_current_equipment() is Gun:
		get_current_equipment().spread_changed.connect(update_aim_cone)
		
	# make starting item
	
func set_shortcut_label(num: int) -> void:
	$ShortcutLabel.text = str(num)
	
func _unhandled_input(event: InputEvent) -> void:
	if !InputManager.IsSelected(self):
		return
		
	state_machine.process_input(event)
	
	if Input.is_action_just_pressed("action_one"):
		# do we need to reload?
		if get_current_equipment() != null and !get_current_equipment().ready:
			# start reload
			if action_one_reload_timer.is_stopped():
				action_one_reload_timer.start(get_reload_time())
			
	if Input.is_action_just_pressed("switch_equipment"):
		current_equipped_index += 1
		current_equipped_index = current_equipped_index % equipments.size()
		equipment_changed.emit()
		print("current equipment: " + get_current_equipment().data.equipment_name)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	# make aim line follow mouse cursor
	aim_line.visible = InputManager.IsSelected(self)
	aim_cone.visible = aim_line.visible
	if InputManager.IsSelected(self):
		aim_line.set_point_position(1, get_local_mouse_position().normalized() * 10000)
		aim_cone.rotation = Vector2.ZERO.angle_to_point(get_local_mouse_position())

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

#region Enemy Interaction
func receive_hit(amount: float) -> void:
	health_points -= amount
	health_points = max(health_points, 0)
	if health_points <= 0:
		knocked_out.emit()
		disable_enemy_collision()
		
	health_bar.change_value(health_points)
	health_changed.emit()
	was_attacked.emit()

func add_health(amount: float) -> void:
	if health_points <= 0 and amount > 0:
		revived.emit()
		$CollisionShape2D.disabled = false
		enable_enemy_collision()
		
	health_points += amount
	health_points = min(max_health_points, health_points)
	health_bar.change_value(health_points)
	health_changed.emit()

func reset_health() -> void:
	health_points = max_health_points
	health_bar.change_value(max_health_points, true)
	health_changed.emit()

func is_unconscious() -> bool:
	return health_points <= 0
	
func _on_body_entered(body):
	if body is EnemyUnit:
		receive_hit(body.health_points)
		body.die()

func disable_enemy_collision():
	$CollisionShape2D.call_deferred("set_disabled", true)
	print("disabled collision")
func enable_enemy_collision():
	$CollisionShape2D.call_deferred("set_disabled", false)
	print("enabled collision")
#endregion

#region Equipment management
func get_current_equipment():
	if current_equipped_index < equipments.size():
		return equipments[current_equipped_index]
		
func get_other_equipment():
	if equipments.size() <= 1:
		return null
		
	if current_equipped_index + 1 < equipments.size():
		return equipments[current_equipped_index + 1]
	else:
		return equipments[current_equipped_index - 1]

func set_current_equipment(num: int) -> void:
	if num >= equipments.size():
		push_error("Set equipment index out of bounds")
		return
		
	current_equipped_index = num
	equipment_changed.emit()
	print("current equipment: " + get_current_equipment().data.equipment_name)

func reload_action() -> void:
	if current_equipped_index < equipments.size():
		equipments[current_equipped_index].ready = true
		if equipments[current_equipped_index] is Gun:
			equipments[current_equipped_index].reload()
		reload_sfx.stream = equipments[current_equipped_index].data.reload_sound
		reload_sfx.play()
	else:
		push_error("Reload equipment index out of bounds!")
	
func remove_equipment(num: int) -> void:
	if num < equipments.size():
		equipments.remove_at(num)
		equipment_changed.emit()
#endregion
		
#region Attack UI
func set_movement_line(points) -> void:
	move_line.clear_points()
	move_line.add_point(Vector2.ZERO)
	for pt: Vector2 in points:
		move_line.add_point(pt)

func cone_from_angle(angle: float, radius: float) -> PackedVector2Array:
	# calculate three points of triangle
	var cone = []
	cone.append(Vector2.ZERO)
	cone.append(Vector2.from_angle(angle/2) * radius)
	cone.append(Vector2.from_angle(-angle/2) * radius)
	return cone

func update_attack_cone(progress: float) -> void:
	attack_cone.polygon = cone_from_angle(get_current_equipment().get_spread() * progress, 100000)

func update_aim_cone() -> void:
	if !(get_current_equipment() is Gun):
		return
	var spread: float = get_current_equipment().get_spread()
	aim_cone.polygon = cone_from_angle(spread, 100000)
	attack_full_cone.polygon = cone_from_angle(spread, 100000)
#endregion

func get_interactable_in_range():
	var items_in_range = interaction_area.get_overlapping_areas()
	# get closest thing inside interaction area
	var target
	var dist = INF
	for interactable in items_in_range:
		if dist > interactable.global_position.distance_to(global_position):
			dist = interactable.global_position.distance_to(global_position)
			target = interactable
	
	return target
	
#region Item System
func add_item(item: ItemData) -> void:
	# if it exists, increase level
	if items.find_key(item):
		item.on_exit(self, items[item])
		items[item] += 1
		item.on_enter(self, items[item])
	else:
		items[item] = 1
		item.on_enter(self, items[item])
	
	picked_up_item.emit(item)
		
func reset_items() -> void:
	for item in items.keys():
		item.on_exit(self, items[item])
	items.clear()
#endregion

#region Effect System
func add_effect(effect: EffectObjectData, duration: float):
	var new_eff = EffectObject.new(effect, duration)
	new_eff.timeout.connect(remove_effect)
	effect.effect(self)
	effects.add_child(new_eff)

func remove_effect(effect: EffectObject):
	effect.data.on_exit(self)
	effects.remove_child(effect)
#endregion

#region Stat Change Management
func add_movement_bonus(amount: float) -> void:
	movement_speed_bonus += amount
func get_movement_speed() -> float:
	return (movement_speed + movement_speed_bonus) * movement_speed_multiplier

func add_aim_speed_modifier(amount: float) -> void:
	aim_speed_modifier += amount
func get_aim_time() -> float:
	return equipments[0].get_aim_time() * (1 - aim_speed_modifier)
	
func add_reload_speed_modifier(amount: float) -> void:
	reload_speed_modifier += amount
func get_reload_time() -> float:
	return equipments[0].get_reload_time() * (1 - reload_speed_modifier)
	
func print_unit_stats() -> String:
	var output = "Move Speed: {move_speed}\nReloading Bonus: {reload_speed_bonus}    Aiming Bonus: {aim_speed_bonus}%"
	
	return output.format({
		"move_speed":get_movement_speed(),
		"reload_speed_bonus":int(reload_speed_modifier * 100),
		"aim_speed_bonus":int(aim_speed_modifier*100)})

func print_weapon_stats() -> String:
	var output = ""
	var eq = get_current_equipment()
	if eq is Gun:
		output += "Damage: " + str(eq.get_damage_range().x) + "-" + str(eq.get_damage_range().y) + "    "
		output += "Aim Time: " + str(eq.get_aim_time()) + "s    "
		output += "Reload Time: " + str(eq.get_reload_time()) + "s\n"
		
		output += "Spread: " + str(DW_ToolBox.TrimDecimalPoints(eq.get_spread()/PI * 180, 1)) + " deg    "
		output += "Bullet Speed: " + str(eq.get_projectile_speed()) + "    \n"
		
		output += "Penetration: " + str(int(eq.get_penetration() * 100)) + "%"  
	return output
#endregion

#region Experience system
func add_experience(amount: int) -> void:
	print("add " + str(amount) + " experience")
	experience_gained += amount
	experience_changed.emit()

func level_up() -> void:
	experience_gained -= required_exp_amount(current_level)
	current_level += 1
	print("level up to " + str(current_level))
	level_increased.emit()
	return

func is_level_up_ready() -> bool:
	return experience_gained >= required_exp_amount(current_level)
	
func required_exp_amount(level: int) -> int:
	return level * 1000
	
#endregion
