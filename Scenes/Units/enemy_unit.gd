extends RigidBody2D
class_name EnemyUnit

var game_ref

@onready
var state_machine: StateMachine = $StateMachine
@onready
var state_label: Label = $StateLabel

var target_position: Vector2
var follow_player: bool = true

var health_points: float = 100
var max_health_points: float = 100
var armor_points: float = 10
var max_armor_points: float = 10
@onready
var bleed_timer: Timer = $BleedTimer
var is_elite: bool = false

@export
var projectile: PackedScene = null
@export
var attack_range: float = 500

## percentage of radius that is considered a critical hit
var critical_hit_ratio: float = 0.2

var movement_speed: float = 0
var max_movement_speed: float = 0
var movement_speed_modifier: float = 0
var movement_speed_multiplier: float = 1.0
var acceleration: float = 0

var adjust_modifier: float = 8
var speed_adjust_modifier: float = 4

@onready
var health_label: Label = $HealthLabel
var health_bar: DelayedProgressBar

@onready
var sprite: Sprite2D = $Sprite2D/Sprite2D

@onready var hit_sound_player: AudioStreamPlayer2D = $HitSoundPlayer
@onready var crit_sound_player: AudioStreamPlayer2D = $CritSoundPlayer

var death_effect = preload("res://Scenes/Units/death_effect.tscn")
var damage_popup = preload("res://Scenes/damage_popup.tscn")
var dead_enemy_effect = preload("res://Scenes/dead_enemy_effect.tscn")

static var resource_drop_chance: float = 0
var resource_drop = preload("res://Scenes/resource.tscn")

## shootables
static var dynamite_drop_chance: float = 0.1
var dynamite_shootable = preload("res://Scenes/Shootables/dynamite.tscn")

signal on_death


func on_spawn(speed: float, health: int) -> void:
	var move_dir = global_position.direction_to(target_position)
	apply_central_impulse(move_dir * speed)
	health_points = health
	max_health_points = health
	movement_speed = speed
	max_movement_speed = speed
	health_bar = $HealthBar
	health_bar.set_max(health)
	health_bar.change_value(health, true)

func _ready():
	state_machine.init(self)
	
	health_label.text = str(int(health_points))
	#health_label.text = "(" + str(int(armor_points)) + ")" + str(int(health_points))
	bleed_timer.timeout.connect(
		make_blood_splatter_eff.bind(-linear_velocity.normalized(), 3))
		
func _process(_delta: float) -> void:
	target_position = InputManager.selected_unit.global_position
	
	state_machine.process_frame(_delta)

# returns actual amount of HP decreased of self
func receive_hit(damage_amount: float, critical: bool = false, projectile_dir: Vector2 = Vector2.ZERO) -> int:
	var new_popup = damage_popup.instantiate()
		
	if critical:
		$CritArea/Sprite2D2/AnimationPlayer.play("crit_hit_animation")
		damage_amount *= 2
		new_popup.modulate = Color.YELLOW
		crit_sound_player.play()
		if projectile_dir:
			make_blood_splatter_eff(projectile_dir, 15, 2)
	else:
		if projectile_dir:
			make_blood_splatter_eff(projectile_dir, 5)
		hit_sound_player.play()
		
	new_popup.set_label(str(int(damage_amount)))
	new_popup.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	get_tree().root.add_child(new_popup)
	
	var effective_damage: int = min(damage_amount, health_points)
	health_points -= damage_amount
	
	# reduce speed if below half health
	if health_points < max_health_points / 2:
		movement_speed = max_movement_speed * 0.75
		
	if health_points <= 0:
		die()
		if projectile_dir:
			make_blood_splatter_eff(projectile_dir, 50)
	else:
		health_bar.change_value(int(health_points))
		#health_label.text = "(" + str(int(armor_points)) + ")" + str(int(health_points))
		health_label.text = str(int(health_points))
		
		if health_points < max_health_points:
			bleed_timer.start(2)
		
		$Sprite2D/AnimationPlayer.play("hit_animation")
		
	CameraControl.camera.shake_screen(10,200)
	
	return effective_damage
	
func die():
	var new_effect: CPUParticles2D = death_effect.instantiate()
	new_effect.global_position = global_position
	get_tree().root.add_child(new_effect)
	
	if randf() < EnemyUnit.resource_drop_chance:
		var new_drop: ResourceDrop = resource_drop.instantiate()
		new_drop.amount = randi_range(1, 5)
		new_drop.global_position = global_position
		new_drop.picked_up.connect(game_ref.change_resource)
		game_ref.resource_node.call_deferred("add_child", new_drop)
		
	if randf() < EnemyUnit.dynamite_drop_chance:
		var new_drop: Shootable = dynamite_shootable.instantiate()
		new_drop.global_position = global_position
		game_ref.shootables.call_deferred("add_child", new_drop)
	
	get_parent().remove_child(self)
	on_death.emit()
	queue_free()
	
func _physics_process(delta) -> void:
	state_machine.process_physics(delta)
	
	# flip sprite based on movement
	# right is false
	sprite.flip_h = linear_velocity.x <= 0

func get_movement_speed() -> float:
	return movement_speed * movement_speed_multiplier + movement_speed_modifier

## determines if the received hit is a critical hit
## a hit is critical when its trajectory line's shortest distance from the center is smaller than crit hit range
## can get that number by multiplying radius with sin(bullet direction and hit direction)
func determine_critical_hit(bullet_dir: Vector2, hit_pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(hit_pos, hit_pos + bullet_dir.normalized() * 1000, 16)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	var hit_line: Line2D = $HitLine
	hit_line.set_point_position(0, hit_pos - global_position)
	hit_line.set_point_position(1, hit_pos + bullet_dir.normalized() * 1000 - global_position)
		
	if result.is_empty():
		hit_line.default_color = Color.WHITE
	else:
		hit_line.default_color = Color.YELLOW
	
	return !result.is_empty()

func make_blood_splatter_eff(direction, count: int = 50, intensity_scale: float = 1) -> void:
	var new_dead_eff = dead_enemy_effect.instantiate()
	new_dead_eff.global_position = global_position
	
	var particles: CPUParticles2D = new_dead_eff.get_node("CPUParticles2D")
	particles.direction = direction
	particles.amount = count
	if is_elite:
		particles.amount *= 2
		intensity_scale += 0.5
	particles.initial_velocity_min *= intensity_scale
	particles.initial_velocity_max *= intensity_scale
	particles.emitting = true
	game_ref.blood_splatter.call_deferred("add_child", new_dead_eff)

func increase_size(rate: float) -> void:
	$Sprite2D.scale *= rate
	$CollisionShape2D.scale *= rate

## returns whether player unit is inside attack range of self
func player_inside_range() -> bool:
	if InputManager.selected_unit == null:
		return false
		
	return global_position.distance_to(InputManager.selected_unit.global_position) < attack_range
