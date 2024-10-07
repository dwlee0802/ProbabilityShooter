extends Unit
class_name PlayerUnit

@onready
var state_label: Label = $StateLabel

@onready
var unit_sprite: Sprite2D = $UnitSprite

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

@onready
var safe_zone_timer: Timer = $SafeZoneTimer

var active_reload_length: int = 10
var active_reload_range: Vector2i = Vector2i.ZERO
@export
var active_reload_available: bool = true
var active_reload_failed: bool = false
var active_reload_success_sound = preload("res://Sound/UI/confirmation_002.ogg")
var active_reload_fail_sound = preload("res://Sound/UI/error_006.ogg")
@onready
var active_reload_sound_player: AudioStreamPlayer = $ActiveReloadSound
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

@onready
var weapon_one: WeaponComponent = $WeaponOne
@onready
var weapon_two: WeaponComponent = $WeaponTwo

@onready
var bullet_generator_component: BulletGenerator = $BulletGeneratorComponent
#endregion

@onready
var action_one_reload_timer: Timer = $ActionOneReloadTimer
@onready
var secondary_reload_timer: Timer = $SecondaryReloadTimer

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
var attack_cone: Polygon2D = $AttackFullCone/AttackCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone
@onready
var aim_cone: Polygon2D = $AimCone
@onready
var queued_cones: Node2D = $QueuedCones
#endregion

#region Items System
var inventory = []
var inventory_max_count: int = 4
@onready
var interaction_area: Area2D = $InteractionArea
var interaction_target: Interactable = null
var enchant_mode: bool = false
#endregion

## sound
@onready var gunshot_sfx: AudioStreamPlayer2D = $GunshotSoundPlayer
@onready var reload_sfx: AudioStreamPlayer2D = $ReloadSoundPlayer

@onready
var shade_animation: AnimationPlayer = $UnitSprite/ShadeAnimationPlayer

#region Experience System
@export_category("Experience System")
@export
var experience_gained: int = 0
var current_level: int = 1
var upgrade_options = []

@export
var trait_chance_increase_per_level: float = 0.01

@export
var level_per_upgrade: int = 5
@export
var upgrades_ready_count: int = 0

@onready
var exp_gained_sound: AudioStreamPlayer = $ExpGainedSound
@onready
var level_up_animation: AnimationPlayer = $LevelUpEffect/LevelUpAnimationPlayer
@onready
var level_up_sound: AudioStreamPlayer = $LevelUpEffect/AudioStreamPlayer
@onready
var push_back_area: Area2D = $LevelUpEffect/PushBackArea
@export
var push_back_strength: float = 1000
@onready
var push_back_sound: AudioStreamPlayer = $LevelUpEffect/PushBackSound

@export
var level_up_debug: bool = false
@export
var level_up_debug_amount: int = 300
#endregion

#region Charge System
@export_category("Charge System")
@export
var charge: float = 0
@export
var max_charge: float = 50.0
@export
var charge_use_rate: float = 5.0
var ability_on: bool = false
@onready
var ability_particles: CPUParticles2D = $AbilityActiveParticles
@onready
var ability_start_particles: CPUParticles2D = $AbilityStartParticles
@onready
var ability_use_sound: AudioStreamPlayer = $AbilityActiveSound
@onready
var ability_finish_sound: AudioStreamPlayer = $AbilityFinishedSound
@onready
var ripple_effect: ColorRect = $RippleEffect
@onready
var ability_start_line_particles: CPUParticles2D = $AbilityLineParticels
#endregion

## WASD Movement Component Node
@onready
var movement_component: WASDMovementComponent = $MovementComponent

@export_category("Debugging")
@export
var invinsible: bool = false

#region Signals
signal was_selected
signal deselected
signal health_changed
signal healed
signal was_attacked
signal knocked_out
signal revived
signal equipment_changed
signal picked_up_item(item)
signal inventory_changed
signal experience_changed
signal added_experience(amount)
signal level_increased
signal stats_changed
signal actioned
signal bullets_changed
signal reload_started
signal reload_complete
signal active_reload_success
signal charge_changed(amount)
signal used_ability
signal upgrade_ready
#endregion


func _ready() -> void:
	# instantiate gun objects
	#for eq: EquipmentData in starting_equipments:
		#if eq is RayGunData:
			#equipments.append(RayGun.new(eq))
		#elif eq is GrenadeData:
			#equipments.append(Grenade.new(eq))
		#elif eq is EffectorData:
			#equipments.append(Effector.new(eq))
		#else:
			#equipments.append(Gun.new(eq))
			
	Gun.bullet_generator = bullet_generator_component
	weapon_one.weapon.reload()
	weapon_two.weapon.reload()
	
	equipment_changed.connect(update_aim_cone)
	update_aim_cone()
	print("equipped " + weapon_one.weapon_data.equipment_name)
	print("equipped " + weapon_two.weapon_data.equipment_name)
	
	# cone colors
	aim_cone.color = aim_color
	attack_cone.color = attack_color
	attack_full_cone.color = background_color
	
	# unit health
	health_points = int(max_health_points)
	health_bar.set_max(max_health_points)
	health_bar.change_value(health_points)
	
	if get_current_equipment() is Gun:
		get_current_equipment().spread_changed.connect(update_aim_cone)
	
	safe_zone_timer.timeout.connect(receive_hit.bind(1))
	# make starting item
	
	stats_changed.emit()
	
	InputManager.camera = $Camera2D
	
func set_shortcut_label(num: int) -> void:
	$ShortcutLabel.text = str(num)
	
func _unhandled_input(_event: InputEvent) -> void:
	if is_unconscious():
		return

func _physics_process(delta: float) -> void:
	if is_unconscious():
		return
		
	movement_component.physics_update(self, delta)
		
	if linear_velocity.x > 100:
		unit_sprite.skew = 0.10
		if Input.is_action_pressed("run"):
			unit_sprite.skew *= 2
	elif linear_velocity.x < -100:
		unit_sprite.skew = -0.10
		if Input.is_action_pressed("run"):
			unit_sprite.skew *= 2
	else:
		unit_sprite.skew = 0
	
	if Input.is_action_just_pressed("action_one") and Input.is_physical_key_pressed(KEY_1):
		print("use item one on left")
		use_item(0, weapon_one)
	if Input.is_action_just_pressed("action_one") and Input.is_physical_key_pressed(KEY_2):
		print("use item two on left")
		use_item(1, weapon_one)
	if Input.is_action_just_pressed("action_one") and Input.is_physical_key_pressed(KEY_3):
		print("use item three on left")
		use_item(2, weapon_one)
	if Input.is_action_just_pressed("action_one") and Input.is_physical_key_pressed(KEY_4):
		print("use item four on left")
		use_item(3, weapon_one)
		
	if Input.is_action_just_pressed("action_two") and Input.is_physical_key_pressed(KEY_1):
		print("use item one on right")
		use_item(0, weapon_two)
	if Input.is_action_just_pressed("action_two") and Input.is_physical_key_pressed(KEY_2):
		print("use item two on right")
		use_item(1, weapon_two)
	if Input.is_action_just_pressed("action_two") and Input.is_physical_key_pressed(KEY_3):
		print("use item three on right")
		use_item(2, weapon_two)
	if Input.is_action_just_pressed("action_two") and Input.is_physical_key_pressed(KEY_4):
		print("use item four on right")
		use_item(3, weapon_two)
		
func _input(_event: InputEvent) -> void:
	aim_cone.rotation = Vector2.ZERO.angle_to_point(get_local_mouse_position())
	
	if Input.is_action_just_pressed("use_ability") and is_ability_ready() and !ability_on:
		ability_on = true
		used_ability.emit()
		ability_start_particles.emitting = true
		ability_start_line_particles.emitting = true
		ability_use_sound.play()
		reload_action()
		push_back()
	
	if Input.is_action_just_pressed("interact") and interaction_target != null:
		print("interact with " + interaction_target.name)
		interaction_target.use(self)
		
func _process(_delta: float) -> void:
	ability_particles.emitting = ability_on
	ripple_effect.visible = ability_on
	if ability_on:
		weapon_one.reload_timer.speed = 2
		weapon_two.reload_timer.speed = 2
		weapon_one.aim_timer.speed = 2
		weapon_two.aim_timer.speed = 2
		
		charge -= charge_use_rate * _delta
		if charge <= 0:
			ability_on = false
			charge = 0
			
			ability_finish_sound.play()
			weapon_one.reload_timer.speed = 1
			weapon_two.reload_timer.speed = 1
			weapon_one.aim_timer.speed = 1
			weapon_two.aim_timer.speed = 1
		
	return
	## autofail active reload if past range
	#if !equipments[0].ready and !action_one_reload_timer.is_stopped():
		#if active_reload_available:
			#var current_point: float = (1 - action_one_reload_timer.time_left / action_one_reload_timer.wait_time) * 100
			#if current_point > active_reload_range.y:
				#active_reload_available = false
				#print("active reload fail!")
	
#region Enemy Interaction
func receive_hit(amount: float) -> void:
	if is_unconscious():
		return
		
	health_points -= amount
	health_points = max(health_points, 0)
	if health_points <= 0 and !invinsible:
		make_unconscious()
		
	health_bar.change_value(health_points)
	health_changed.emit()
	was_attacked.emit()

func make_unconscious() -> void:
	if invinsible:
		return
		
	ability_on = false
	charge = 0
	charge_changed.emit()
	
	knocked_out.emit()
	#disable_enemy_collision()
	weapon_one.reset()
	weapon_two.reset()
	weapon_one.process_mode = Node.PROCESS_MODE_DISABLED
	weapon_two.process_mode = Node.PROCESS_MODE_DISABLED
	aim_cone.visible = false
	
func add_health(amount: float) -> void:
	if health_points <= 0 and amount > 0:
		revived.emit()
		$CollisionShape2D.disabled = false
		enable_enemy_collision()
		
	health_points += amount
	health_points = min(max_health_points, health_points)
	health_bar.change_value(health_points)
	healed.emit()

func reset_health() -> void:
	weapon_one.process_mode = Node.PROCESS_MODE_INHERIT
	weapon_two.process_mode = Node.PROCESS_MODE_INHERIT
	health_points = max_health_points
	health_bar.change_value(max_health_points, true)
	health_changed.emit()
	enable_enemy_collision()
	weapon_one.reset()
	weapon_two.reset()
	aim_cone.visible = false
	global_position = Vector2.ZERO

func reset_exp() -> void:
	experience_gained = 0
	current_level = 1
	experience_changed.emit()
	
func is_unconscious() -> bool:
	return health_points <= 0 and !invinsible
	
func _on_body_entered(body) -> void:
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

func get_current_equipment_timer() -> Timer:
	if current_equipped_index == 0:
		return action_one_reload_timer
	else:
		return secondary_reload_timer
		
func get_other_equipment():
	if equipments.size() <= 1:
		return null
		
	if current_equipped_index + 1 < equipments.size():
		return equipments[current_equipped_index + 1]
	else:
		return equipments[current_equipped_index - 1]

func get_other_equipment_timer() -> Timer:
	if current_equipped_index == 1:
		return action_one_reload_timer
	else:
		return secondary_reload_timer
		
func has_secondary() -> bool:
	return equipments.size() > 1
	
func set_current_equipment(num: int) -> void:
	if num >= equipments.size():
		push_error("Set equipment index out of bounds")
		return
		
	current_equipped_index = num
	equipment_changed.emit()
	print("current equipment: " + get_current_equipment().data.equipment_name)

#func start_reload_process(_eq_num: int = 0) -> void:
	#if action_one_reload_timer.is_stopped():
		#print("Start Reload Process")
		#active_reload_available = true
		#active_reload_failed = false
		#action_one_reload_timer.start(get_reload_time(0))
		#var active_reload_start_point: int = randi_range(50, 70)
		#active_reload_range = Vector2i(active_reload_start_point, active_reload_start_point + active_reload_length)
		##print("active reload range: " + str(active_reload_range))
		#reload_started.emit()
		
## called after reloading process is finished
func reload_action() -> void:
	print("Reload complete")
	if weapon_one != null:
		weapon_one.active_reload_available = true
		weapon_one.weapon.reload()
	if weapon_two != null:
		weapon_two.active_reload_available = true
		weapon_two.weapon.reload()
	
func remove_equipment(num: int) -> void:
	if num < equipments.size():
		equipments.remove_at(num)
		equipment_changed.emit()
#endregion
		
#region Attack UI
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
		
	if bullet_generator_component.items.find_key(item):
		item.on_exit(self, bullet_generator_component.items[item])
		bullet_generator_component.items[item] += 1
		item.on_enter(self, bullet_generator_component.items[item])
	else:
		bullet_generator_component.items[item] = 1
		item.on_enter(self, bullet_generator_component.items[item])
	
	picked_up_item.emit(item)
	stats_changed.emit()
		
func reset_items() -> void:
	for item in items.keys():
		item.on_exit(self, items[item])
	items.clear()
	stats_changed.emit()
	bullet_generator_component.reset_stats()
	
func add_to_inventory(item: ItemData) -> void:
	if item:
		if inventory.size() < inventory_max_count:
			inventory.append(item)
			print("Added " + str(item) + " to inventory.")
			inventory_changed.emit()
		else:
			print("Inventory full")
	else:
		push_warning("Add null item to inventory.")

func use_item(item_index, target) -> void:
	if item_index < inventory.size():
		print("use " + str(inventory[item_index]) + " on " + str(target))
		if target.weapon is Gun:
			target.weapon.apply_item_to_bullets(inventory[item_index])
		inventory.remove_at(item_index)
		inventory_changed.emit()
	
func remove_from_inventory(item: ItemData) -> void:
	var index: int = inventory.find(item)
	if index < 0:
		push_warning("Trying to remove item that is not in inventory.")
	else:
		inventory.remove_at(index)
		
func _on_interaction_area_changed(_area) -> void:
	find_closest_interactable()

func find_closest_interactable():
	var targets = interaction_area.get_overlapping_areas()
	if targets.size() > 0:
		var closest = targets[0]
		var dist: float = global_position.distance_to(closest.global_position)
		for item in targets:
			if item is DroppedItem:
				item.set_highlight(false)
			if global_position.distance_to(item.global_position) < dist:
				closest = item
		interaction_target = closest
		DroppedItem.selected_item = interaction_target
		
		#print("New interaction target: " + interaction_target.name)
	else:
		interaction_target = null
		DroppedItem.selected_item = interaction_target
		
#endregion

#region Effect System
func add_effect(effect: EffectObjectData, duration: float):
	var new_eff = EffectObject.new(effect, duration)
	new_eff.timeout.connect(remove_effect)
	effect.effect(self)
	effects.add_child(new_eff)
	stats_changed.emit()

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
func get_reload_time(num: int = 0) -> float:
	return equipments[num].get_reload_time() * (1 - reload_speed_modifier)
	
func print_unit_stats() -> String:
	var output = "Move Speed: {move_speed}\nReloading Bonus: {reload_speed_bonus}    Aiming Bonus: {aim_speed_bonus}%"
	
	return output.format({
		"move_speed":get_movement_speed(),
		"reload_speed_bonus":int(reload_speed_modifier * 100),
		"aim_speed_bonus":int(aim_speed_modifier * 100)})

func print_weapon_stats() -> String:
	var output = ""
	var eq = get_current_equipment()
	if eq is Gun:
		output += "Damage: " + str(eq.get_damage_range().x) + "-" + str(eq.get_damage_range().y) + "    "
		output += "Aim Time: " + str(DW_ToolBox.TrimDecimalPoints(get_aim_time(), 2)) + "s    "
		output += "Reload Time: " + str(get_reload_time()) + "s\n"
		
		output += "Spread: " + str(DW_ToolBox.TrimDecimalPoints(eq.get_spread()/PI * 180, 1)) + " deg    "
		output += "Bullet Speed: " + str(eq.get_projectile_speed()) + "    \n"
		
		output += "Penetration: " + str(int(eq.get_penetration() * 100)) + "%"  
	return output
#endregion

#region Experience system
func add_experience(amount: int) -> void:
	#print("add " + str(amount) + " experience")
	experience_gained += amount
	experience_changed.emit()
	added_experience.emit(amount)
	
	if is_level_up_ready():
		level_up()
		if current_level % level_per_upgrade == 0:
			upgrades_ready_count += 1
			upgrade_ready.emit()

func exp_orb_effect() -> void:
	shade_animation.play("RESET")
	shade_animation.play("exp_gained")
	exp_gained_sound.play()
	
func level_up() -> void:
	experience_gained -= required_exp_amount(current_level)
	current_level += 1
	print("level up to " + str(current_level))
	level_increased.emit()
	
	bullet_generator_component.add_trait_chance_bonus(trait_chance_increase_per_level)
	stats_changed.emit()
	level_up_sound.play()
	push_back()
	
	return

func push_back() -> void:
	for body in push_back_area.get_overlapping_bodies():
		if body is EnemyUnit:
			var strength: float = push_back_strength * body.global_position.distance_to(global_position) / 1500.0
			body.apply_central_impulse(strength * global_position.direction_to(body.global_position))
	for body in push_back_area.get_overlapping_areas():
		if body is Projectile and !body.is_player:
			body.queue_free()
	push_back_sound.play()
	CameraControl.camera.shake_screen(40,200)
	
func is_level_up_ready() -> bool:
	return experience_gained >= required_exp_amount(current_level)

func is_upgrade_ready() -> bool:
	return upgrades_ready_count > 0
	
## amount needed to proceed to next level
func required_exp_amount(level: int) -> int:
	if level_up_debug:
		return level_up_debug_amount
	return 500 + level * 250
	
#endregion

#region Charge System
func add_charge(amount: int) -> void:
	if amount <= 0:
		return
		
	charge += amount
	if charge > max_charge:
		charge = max_charge
	charge_changed.emit()
		
func add_charge_on_hit(_total: int, amount: int) -> void:
	if amount <= 0:
		return
		
	charge += amount
	if charge > max_charge:
		charge = max_charge
	charge_changed.emit()

func is_ability_ready() -> bool:
	return charge == max_charge
#endregion

func set_eye_colors(left: Color = Color.BLACK, right: Color = Color.BLACK):
	$UnitSprite/LeftEye.self_modulate = left
	$UnitSprite/RightEye.self_modulate = right
