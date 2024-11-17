extends Unit
class_name PlayerUnit

var upgrade_manager: UpgradesManager

@onready
var state_label: Label = $StateLabel

@onready
var unit_sprite: Sprite2D = $UnitSprite

#region Unit Stat Variables
@export_category("Unit Stats")
@onready
var stat_component: StatComponent = $StatComponent

@export
var movement_speed: float = 100
var movement_speed_bonus: float = 0
var movement_speed_multiplier: float = 1.0
var is_running: bool = false
@onready
var movement_particle: CPUParticles2D = $MovementParticles
@export
var temp_color: Color = Color.WHITE
var damage_bonus: Vector2i = Vector2i(0, 0)
@export
var health_points: float = 500
@export
var max_health_points: int = 500
@onready
var health_bar: DelayedProgressBar = $HealthBar
var aim_speed_modifier: float = 0
var reload_speed_modifier: float = 0

var hit_knockback: float = 8000

@export
var _base_hit_invincible_time: float = 0.5
var hit_invincibility_time: float = 0.5
var invincible_timer: Timer
@onready
var hit_animation: AnimationPlayer = $UnitSprite/AnimationPlayer

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
@onready var hurt_sfx: AudioStreamPlayer = $SoundEffects/HurtSound
@onready
var footstep_component: FootstepComponent = $SoundEffects/FootstepComponent
@onready
var heal_sfx: AudioStreamPlayer = $SoundEffects/HealSound

@onready
var shade_animation: AnimationPlayer = $UnitSprite/ShadeAnimationPlayer

#region Experience System
@export_category("Experience System")
@export
var experience_gained: int = 0
@export
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

#region Teleportation System
@export_category("Teleport System")
## Timer that represents the time needed to charge the teleporter
var teleport_timer: Timer
@export
var teleporter_charge_time: float = 90.0
var current_crystal_count: int = 0
var crystals_needed: int = 3
@onready
var teleporter_info: Control = $TeleportationInfo
@export
var crystal_color: Color = Color.AQUAMARINE

## safe zone system
@onready
var safe_zone_timer: Timer = $SafeZoneTimer
var safe_zone_center: Vector2 = Vector2.ZERO
var safe_zone_active: bool = true
@export
var safe_zone_radius: float = 3000.0
var safe_zone_damage: int = 1
var safe_zone_time_limit: float = 1
#endregion

## Buff system
var buffs = {}
@onready
var buffs_node: Node = $Buffs

## WASD Movement Component Node
@onready
var movement_component: WASDMovementComponent = $MovementComponent
@onready
var dash_progress_bar: RadialProgress = $DashCooldown/RadialProgress
@onready
var dash_effect: CPUParticles2D = $DashParticles
@onready
var dash_sound: AudioStreamPlayer = $SoundEffects/DashSound

@export_category("Debugging")
@export
var invinsible: bool = false
@export
var level_up_debug: bool = false
@export
var level_up_debug_amount: int = 300
@export
var crystal_debug: bool = false
@export
var debug_crystal_amount: int = 0

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
signal teleport_started
signal teleport_finished
signal buff_entered(buff)
#endregion


func _ready() -> void:
	Gun.bullet_generator = bullet_generator_component
	weapon_one.bullet_generator = $BulletGeneratorComponent
	weapon_two.bullet_generator = $BulletGeneratorComponent
	weapon_one.reload()
	weapon_two.reload()
	
	weapon_one.activated.connect(knock_back.bind(weapon_one.muzzle_point))
	weapon_two.activated.connect(knock_back.bind(weapon_two.muzzle_point))
	
	weapon_one.activated.connect(UpgradesManager.process_event.bind(Event.new(self, global_position, null, Event.EventCode.PLAYER_SHOOT)))
	weapon_two.activated.connect(UpgradesManager.process_event.bind(Event.new(self, global_position, null, Event.EventCode.PLAYER_SHOOT)))
	
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
	
	if crystal_debug:
		for i in range(debug_crystal_amount):
			pick_up_crystal()
	update_crystal_icon_count()
	
	teleport_timer = Timer.new()
	teleport_timer.autostart = false
	teleport_timer.one_shot = true
	teleport_timer.timeout.connect(teleporter_charge_finished)
	add_child(teleport_timer)
	
	safe_zone_timer.timeout.connect(receive_hit.bind(safe_zone_damage))
	# make starting item
	
	stats_changed.emit()
	
	InputManager.camera = $Camera2D
	
	weapon_one.reload_complete.connect(UpgradesManager.process_event.bind(Event.new(self, global_position, null, Event.EventCode.PLAYER_RELOAD)))
	weapon_two.reload_complete.connect(UpgradesManager.process_event.bind(Event.new(self, global_position, null, Event.EventCode.PLAYER_RELOAD)))
	
	movement_component.dashed.connect(dash_sound.play)
	
	# invincible timer
	invincible_timer = Timer.new()
	invincible_timer.autostart = false
	invincible_timer.one_shot = true
	invincible_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(invincible_timer)
	
	set_hit_invincible_time(_base_hit_invincible_time)
	
	footstep_component.unit = self
	
	stat_component = $StatComponent
	stat_component.unit = self
	
func set_shortcut_label(num: int) -> void:
	$ShortcutLabel.text = str(num)
	
func _unhandled_input(_event: InputEvent) -> void:
	if is_unconscious():
		return

func _physics_process(delta: float) -> void:
	if is_unconscious():
		return
		
	movement_component.physics_update(self, delta)
	
	movement_particle.emitting = linear_velocity.length() > 1
	
	is_running = false
	if linear_velocity.x > 100:
		unit_sprite.skew = 0.10
		if Input.is_action_pressed("run"):
			unit_sprite.skew *= 2
			is_running = true
	elif linear_velocity.x < -100:
		unit_sprite.skew = -0.10
		if Input.is_action_pressed("run"):
			unit_sprite.skew *= 2
			is_running = true
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
	
	if Input.is_action_just_pressed("dash"):
		movement_component.input_update(self)
	if !movement_component.dash_timer.is_stopped():
		if !dash_progress_bar.visible:
			dash_progress_bar.visible = true
			dash_effect.emitting = true
			dash_effect.direction = -linear_velocity.normalized()
		dash_progress_bar.progress = (1 - movement_component.dash_timer.time_left / movement_component.dash_cooldown) * 100
	else:
		if dash_progress_bar.visible:
			dash_progress_bar.visible = false
		
	# check outside or inside safe zone
	if safe_zone_active:
		if !is_inside_safe_zone():
			if safe_zone_timer.is_stopped():
				safe_zone_timer.start(safe_zone_time_limit)
		else:
			if !safe_zone_timer.is_stopped():
				safe_zone_timer.stop()
	else:
		if !safe_zone_timer.is_stopped():
			safe_zone_timer.stop()
		
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
	
	if Input.is_action_just_pressed("use_teleport"):
		if can_use_teleport():
			start_teleport_charging()
		
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
	
	if !teleport_timer.is_stopped():
		var teleport_label: Label = teleporter_info.get_node("TeleportLabel")
		teleport_label.text = str(int(teleporter_charge_time) - int(teleport_timer.time_left)) + " / " + str(int(teleporter_charge_time))
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
	if !invincible_timer.is_stopped():
		return
	invincible_timer.start(hit_invincibility_time)
	hit_animation.play("hit_blink")
	
	health_points -= amount
	health_points = max(health_points, 0)
	if health_points <= 0 and !invinsible:
		make_unconscious()
		
	health_bar.change_value(health_points)
	health_changed.emit()
	was_attacked.emit()
	hurt_sfx.play()

func set_hit_invincible_time(new_time: float) -> void:
	hit_invincibility_time = new_time
	hit_animation.speed_scale = _base_hit_invincible_time / hit_invincibility_time
	
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
	
	set_deferred("freeze", true)
	teleport_timer.stop()
	
func add_health(amount: float) -> void:
	if health_points <= 0 and amount > 0:
		revived.emit()
		$CollisionShape2D.disabled = false
		enable_enemy_collision()
		
	health_points += amount
	health_points = min(max_health_points, health_points)
	health_bar.change_value(health_points)
	healed.emit()
	heal_sfx.play()
	$HealParticles.emitting = true

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
	bullet_generator_component.reset_stats()

func reset_crystals() -> void:
	current_crystal_count = 0
	update_crystal_icon_count()
	teleport_timer.stop()
	
func is_unconscious() -> bool:
	return health_points <= 0 and !invinsible
	
func _on_body_entered(body) -> void:
	if body is EnemyUnit:
		receive_hit(1)
		#body.die()
		apply_central_impulse(body.global_position.direction_to(global_position) * hit_knockback)

func on_projectile_hit(proj: Projectile) -> void:
	if !proj.is_player:
		receive_hit(1)
	
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
		weapon_one.reload()
	if weapon_two != null:
		weapon_two.active_reload_available = true
		weapon_two.reload()
	
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
	
func add_to_inventory(item: ItemData) -> bool:
	if item:
		if inventory.size() < inventory_max_count:
			inventory.append(item)
			print("Added " + str(item) + " to inventory.")
			inventory_changed.emit()
			return true
		else:
			print("Inventory full")
	else:
		push_warning("Add null item to inventory.")
	
	return false

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

func clear_inventory() -> void:
	inventory.clear()
	inventory_changed.emit()
	
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
	movement_component.add_movement_speed(amount)
func get_movement_speed() -> float:
	return (movement_speed + movement_speed_bonus) * movement_speed_multiplier

func set_pickup_range(radius: float) -> void:
	var pickup_area: CircleShape2D = $PickupArea/CollisionShape2D.shape
	pickup_area.set_radius(radius)
	
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
	push_back_area.get_node("Sprite2D/AnimationPlayer").play("push_back")
	CameraControl.camera.shake_screen(40,200)
	
func is_level_up_ready() -> bool:
	return experience_gained >= required_exp_amount(current_level)

func is_upgrade_ready() -> bool:
	return upgrades_ready_count > 0
	
## amount needed to proceed to next level
func required_exp_amount(level: int) -> int:
	if level_up_debug:
		return level_up_debug_amount
	return 500 + level * 200
	
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

#region Teleporter System
func pick_up_crystal() -> void:
	current_crystal_count += 1
	update_crystal_icon_count()

func update_crystal_icon_count() -> void:
	var container: HBoxContainer = teleporter_info.get_node("HBoxContainer")
	var label: Label = teleporter_info.get_node("TeleportLabel")
	for i in range(container.get_child_count()):
		container.get_child(i).visible = i < current_crystal_count
	if current_crystal_count >= crystals_needed:
		label.text = "Press T to start Teleportation"
	else:
		label.text = ""

func can_use_teleport() -> bool:
	return current_crystal_count >= crystals_needed

func start_teleport_charging() -> void:
	teleport_timer.start(teleporter_charge_time)
	teleport_started.emit()
	safe_zone_active = true
	safe_zone_center = global_position
	
	var label: Label = teleporter_info.get_node("TeleportLabel")
	label.text = ""

func teleporter_charge_finished() -> void:
	teleport_finished.emit()
	print("teleport finished")
	
func is_inside_safe_zone() -> bool:
	return global_position.distance_to(safe_zone_center) <= safe_zone_radius
	
#endregion

func set_eye_colors(left: Color = Color.BLACK, right: Color = Color.BLACK):
	$UnitSprite/LeftEye.self_modulate = left
	$UnitSprite/RightEye.self_modulate = right

func knock_back(node: Node2D) -> void:
	apply_central_impulse(-global_position.direction_to(node.global_position) * 500)

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Pickup:
		body.on_pickup(self)

# check if it already exists
func add_buff(buff: Buff) -> void:
	if buffs.find_key(buff.buff_data.name):
		buffs[buff.buff_data.name].add_duration(buff.buff_data.duration)
		buff.queue_free()
	else:
		buffs[buff.buff_data.name] = buff
		buffs_node.add_child(buff)
		buff.enter()
		buff_entered.emit(buff)
	
	print(buffs)

func clear_buffs() -> void:
	buffs.clear()
	DW_ToolBox.RemoveAllChildren(buffs_node)
