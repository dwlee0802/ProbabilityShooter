extends RigidBody2D
class_name EnemyUnit

var game_ref
var upgrade_manager: UpgradesManager

@onready
var state_machine: StateMachine = $StateMachine
@onready
var state_label: Label = $StateLabel

@onready
var nav: NavigationAgent2D = $NavigationAgent2D

var color: Color = Color.DARK_RED

var target_position: Vector2
var follow_player: bool = true

var health_points: float = 100
var max_health_points: float = 100
var armor_points: float = 10
var max_armor_points: float = 10
@onready
var bleed_timer: Timer = $BleedTimer
var health_tween: Tween = null
## variable to hold health point amount used for tweening effect
var tweened_health_points: float = 100
var health_hearts: HealthHearts

var last_hit_is_crit: bool = false

var shield: bool = false
@onready
var shield_sound: AudioStreamPlayer = $ShieldHitSound
@onready
var shield_particles: CPUParticles2D = $ShieldParticle
var shield_material = preload("res://Scenes/Units/enemy_unit_shield.tres")

var autoheal_speed: float = 1
## disable autoheal during timer
@onready
var autoheal_stopped_timer: Timer = $AutohealTimer
var autoheal_cooldown: float = 3
@onready
var autoheal_particles: CPUParticles2D = $AutohealParticles

var burning: bool = false
var burn_timer: Timer
static var burn_damage_ratio: float = 0.05
static var burn_damage_amount: float = 4.0
static var burn_damage_cooldown: float = 0.5
@onready
var burn_effect: Node2D = $BurningEffect

@export_category("Ranged Unit Stats")
@export
var projectile: PackedScene = null
@export
var attack_range: float = 500
@export
var projectile_speed: float = 800
@export
var projectile_damage: int = 50
@export
var attack_cooldown: float = 1.0

## percentage of radius that is considered a critical hit
var critical_hit_ratio: float = 0.2

var movement_speed: float = 0
var max_movement_speed: float = 0
var movement_speed_modifier: float = 0
var movement_speed_multiplier: float = 1.0
var acceleration: float = 0

var adjust_modifier: float = 8
var speed_adjust_modifier: float = 4

## ratio of current size compared to default size
var size_modifier: float = 1

@onready
var health_label: Label = $HealthLabel
var health_bar: DelayedProgressBar

@onready
var sprite: Sprite2D = $Sprite2D/Sprite2D
@onready
var unit_sprite: Sprite2D = $Sprite2D

@onready var hit_sound_player: AudioStreamPlayer2D = $HitSoundPlayer
@onready var crit_sound_player: AudioStreamPlayer2D = $CritSoundPlayer

var death_effect = preload("res://Scenes/Units/death_effect.tscn")
var damage_popup = preload("res://Scenes/damage_popup.tscn")
var dead_enemy_effect = preload("res://Scenes/dead_enemy_effect.tscn")

static var resource_drop_chance: float = 0.05
var dropped_item: PackedScene = preload("res://Scenes/Units/dropped_item.tscn")
var exp_orb: PackedScene = preload("res://Scenes/exp_orb.tscn")
var health_orb: PackedScene = preload("res://Scenes/health_orb.tscn")

## shootables
static var dynamite_drop_chance: float = 0.1
var dynamite_shootable = preload("res://Scenes/Shootables/dynamite.tscn")

signal on_death
signal bullet_hit
signal received_hit(total, effective)
signal critical_hit

## upgrade signals
signal on_death_upgrade(self_ref)
signal on_hit_upgrade(self_ref)


func on_spawn(speed: float, health: int) -> void:
	var move_dir = global_position.direction_to(target_position)
	apply_central_impulse(move_dir * speed)
	health_points = health
	max_health_points = health
	tweened_health_points = health
	movement_speed = speed
	max_movement_speed = speed
	health_bar = $HealthBar
	health_bar.set_max(health)
	health_bar.change_value(health, true)
	health_hearts = $HealthHearts
	health_hearts.set_hearts_count(health)

## apply heavy trait
func apply_heavy() -> void:
	max_health_points = max_health_points * 2
	health_points = max_health_points
	tweened_health_points = max_health_points
	health_bar = $HealthBar
	health_bar.set_max(health_points)
	health_bar.change_value(health_points, true)
	increase_size(2.5)
	$Sprite2D.self_modulate = Color.OLIVE
	color = Color.OLIVE

func apply_quick() -> void:
	max_movement_speed = max_movement_speed * 2.0
	movement_speed = max_movement_speed
	increase_size(0.5)
	$Sprite2D.self_modulate = Color.HOT_PINK
	color = Color.HOT_PINK
	
func apply_ranged() -> void:
	attack_range = 2000
	$Sprite2D.self_modulate = Color.ORANGE
	color = Color.ORANGE

func apply_shield() -> void:
	$Sprite2D.material = shield_material
	shield = true

func break_shield() -> void:
	$Sprite2D.material = null
	shield = false
	shield_sound.playing = true
	shield_particles.emitting = true
	
func apply_burning() -> void:
	if health_points <= 0:
		return
		
	burning = true
	burn_timer = Timer.new()
	burn_timer.one_shot = false
	burn_timer.autostart = true
	add_child(burn_timer)
	burn_timer.start(EnemyUnit.burn_damage_cooldown)
	burn_effect.visible = true
	burn_timer.timeout.connect(receive_hit.bind(max(int(max_health_points * EnemyUnit.burn_damage_ratio), 1)))
	
func _ready():
	state_machine.init(self)
	
	update_health_label(int(health_points))
	#health_label.text = "(" + str(int(armor_points)) + ")" + str(int(health_points))
	bleed_timer.timeout.connect(
		make_blood_splatter_eff.bind(-linear_velocity.normalized(), 3))
		
	tweened_health_points = health_points
	
	burn_effect.visible = burning
		
func _process(_delta: float) -> void:
	target_position = InputManager.selected_unit.global_position
	nav.target_position = target_position
	
	state_machine.process_frame(_delta)
	
	#if autoheal_stopped_timer.is_stopped() and health_points + _delta * autoheal_speed < max_health_points:
		#health_points += autoheal_speed * _delta
		#tweened_health_points = health_points
		#autoheal_particles.emitting = true
		#update_health_label(int(health_points))
	#else:
		#autoheal_particles.emitting = false
	
	if health_tween != null and health_tween.is_valid():
		update_health_label(int(tweened_health_points))
		
# returns actual amount of HP decreased of self
func receive_hit(damage_amount: float, critical: bool = false, projectile_dir: Vector2 = Vector2.ZERO, bullet_data: Bullet = null) -> int:
	var new_popup = damage_popup.instantiate()
	last_hit_is_crit = critical
	
	if shield:
		break_shield()
		return 0
		
	if critical:
		damage_amount *= 2
		new_popup.modulate = Color.YELLOW
		new_popup.critical()
		crit_sound_player.play()
		if projectile_dir:
			make_blood_splatter_eff(projectile_dir, 15, 2)
		critical_hit.emit()
	else:
		if projectile_dir:
			make_blood_splatter_eff(projectile_dir, 5)
		hit_sound_player.play()
		
	new_popup.set_label(str(int(damage_amount)))
	new_popup.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	get_tree().root.add_child(new_popup)
	
	var effective_damage: int = min(damage_amount, health_points)
	received_hit.emit(damage_amount, effective_damage)
	bullet_hit.emit()
	on_hit_upgrade.emit(self)
	health_points -= damage_amount
	
	UpgradesManager.process_event(Event.new(self, global_position, null, Event.EventCode.ENEMY_DAMAGED))
	
	#if health_tween:
		#health_tween.kill()
		#health_tween = null
	#var new_tween: Tween = create_tween()
	#health_tween = new_tween
	#
	#new_tween.tween_property(self, "tweened_health_points", health_points, 0.25)
	
	# renew autoheal timer
	#autoheal_stopped_timer.stop()
	#autoheal_stopped_timer.start(autoheal_cooldown)
	
	## reduce speed if below half health
	#if health_points < max_health_points / 2:
		#movement_speed = max_movement_speed * 0.75
		
	health_bar.change_value(int(health_points))
	health_hearts.set_hearts_count(int(health_points))
	if health_points <= 0:
		if bullet_data and bullet_data.vampire:
			game_ref.player_unit.add_health(1)
			
		#health_tween.kill()
		die()
		if projectile_dir:
			make_blood_splatter_eff(projectile_dir, 50)
	else:
		if health_points < max_health_points:
			bleed_timer.start(2)
		
		$Sprite2D/HitEffect/AnimationPlayer.play("hit_animation")
		
	CameraControl.camera.shake_screen(10,200)
	
	return effective_damage

func update_health_label(value: int) -> void:
	health_label.text = str(value)
	
func die():
	UpgradesManager.process_event(Event.new(self, global_position, null, Event.EventCode.ENEMY_DIED))
	
	var new_effect: CPUParticles2D = death_effect.instantiate()
	new_effect.global_position = global_position
	if !last_hit_is_crit:
		new_effect.get_node("CPUParticles2D").amount = 5
		new_effect.get_node("CPUParticles2D").initial_velocity_max -= 1000
		
	get_tree().root.add_child(new_effect)
	
	var new_exp_orb: Node2D = exp_orb.instantiate()
	new_exp_orb.global_position = global_position
	new_exp_orb.player_unit = game_ref.player_unit
	game_ref.resources.add_child(new_exp_orb)
	
	#if randf() < EnemyUnit.resource_drop_chance:
		#var new_drop: ResourceDrop = resource_drop.instantiate()
		#new_drop.amount = randi_range(1, 5)
		#new_drop.global_position = global_position
		#new_drop.picked_up.connect(game_ref.change_resource)
		#game_ref.resource_node.call_deferred("add_child", new_drop)
		
	#if randf() < EnemyUnit.dynamite_drop_chance:
		#var new_drop: Shootable = dynamite_shootable.instantiate()
		#new_drop.global_position = global_position
		#game_ref.shootables.call_deferred("add_child", new_drop)
	
	# spawn random item
	#if randf() < EnemyUnit.resource_drop_chance:
		#var new_drop: DroppedItem = dropped_item.instantiate()
		#new_drop.global_position = global_position
		#new_drop.set_data(Game.upgrade_options.pick_random())
		#game_ref.resources.call_deferred("add_child", new_drop)
	
	on_death.emit()
	on_death_upgrade.emit(self)
	call_deferred("disable_collision")
	set_deferred("freeze", true)
	
	$Sprite2D/AnimationPlayer.play("death")
	
	#get_parent().remove_child(self)
	#queue_free()

func is_dead() -> bool:
	return health_points <= 0

func is_full_health() -> bool:
	return health_points >= max_health_points
	
func _physics_process(delta) -> void:
	state_machine.process_physics(delta)
	
	# flip sprite based on movement
	# right is false
	sprite.flip_h = linear_velocity.x <= 0
	
	if linear_velocity.x > 100:
		unit_sprite.skew = 0.20
	elif linear_velocity.x < -100:
		unit_sprite.skew = -0.20
	else:
		unit_sprite.skew = 0

func get_movement_speed() -> float:
	return movement_speed * movement_speed_multiplier + movement_speed_modifier

## determines if the received hit is a critical hit
## a hit is critical when its trajectory line's shortest distance from the center is smaller than crit hit range
## can get that number by multiplying radius with sin(bullet direction and hit direction)
func determine_critical_hit(bullet_dir: Vector2, hit_pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(hit_pos - bullet_dir.normalized() * 500, hit_pos + bullet_dir.normalized() * 500, 16)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	var hit_line: Line2D = $HitLine
	hit_line.set_point_position(0, hit_pos - global_position - bullet_dir.normalized() * 500)
	hit_line.set_point_position(1, hit_pos + bullet_dir.normalized() * 500 - global_position)
		
	if !result.is_empty() and result["collider"].get_parent() == self:
		hit_line.default_color = Color.YELLOW
		return true
		
	hit_line.default_color = Color.GRAY
	return false

func make_blood_splatter_eff(direction, count: int = 50, intensity_scale: float = 1) -> void:
	var new_dead_eff = dead_enemy_effect.instantiate()
	new_dead_eff.global_position = global_position
	
	var particles: CPUParticles2D = new_dead_eff.get_node("CPUParticles2D")
	particles.direction = direction
	particles.amount = count
	#particles.color = color
	particles.initial_velocity_min *= intensity_scale
	particles.initial_velocity_max *= intensity_scale
	particles.emitting = true
	game_ref.blood_splatter.call_deferred("add_child", new_dead_eff)

func increase_size(rate: float) -> void:
	$Sprite2D.scale *= rate
	$CollisionShape2D.scale *= rate
	size_modifier *= rate

## returns whether player unit is inside attack range of self
func player_inside_range() -> bool:
	if InputManager.selected_unit == null:
		return false
		
	return global_position.distance_to(InputManager.selected_unit.global_position) < attack_range

func disable_collision() -> void:
	$CollisionShape2D.disabled = true
