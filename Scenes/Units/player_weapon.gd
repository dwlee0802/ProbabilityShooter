extends Node2D
class_name WeaponComponent

@export
var weapon_data: GunData = null

var bullet_generator: BulletGenerator

var selected: bool = false

## Bullet Management
var bullets = []
var attack_direction_queue = []
var queued_bullets = []

@export
var all_bullets_penetrate: bool = false

## Stats
var magazine_size: int = 5

@onready
var muzzle_point: Marker2D = $Arm/Node2D/Hand/MuzzlePoint
@onready
var muzzle_smoke: CPUParticles2D = $Arm/Node2D/Hand/MuzzlePoint/CPUParticles2D
## Which action using this weapon is bound to
@export
var action_name: String

@export
var aim_time: float = 1
const projectile_max_speed: float = 10000

@onready
var state_machine: StateMachine = $StateMachine

var reload_timer: ScalableTimer
var aim_timer: ScalableTimer

@export
var active_reload_available: bool = true
var active_reload_failed: bool = false

var queued_attack_cones = []
@onready
var attack_cone: Polygon2D = $AttackFullCone/AttackCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone
@onready
var aim_cone: Polygon2D = $AimCone
@onready
var queued_cones: Node2D = $QueuedCones

@export
var weapon_color: Color = Color.HOT_PINK

@export
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
var muzzle_flash: AnimationPlayer = $Arm/MuzzleFlash/AnimationPlayer
@onready
var recoil_animation: AnimationPlayer = $Arm/AnimationPlayer

## sound
@onready 
var gunshot_sfx: AudioStreamPlayer2D = $GunshotSoundPlayer
@onready 
var reload_sfx: AudioStreamPlayer2D = $ReloadSoundPlayer
@onready
var active_reload_sound_player: AudioStreamPlayer = $ActiveReloadSound
var active_reload_success_sound = preload("res://Sound/UI/confirmation_002.ogg")
var active_reload_fail_sound = preload("res://Sound/UI/error_006.ogg")

#region Active Reload
@export
var active_reload_length: int = 10
var active_reload_range: Vector2i = Vector2i.ZERO
### If active reload selected time is within tolerance, consider it a success
#@export
#var active_reload_tolerance: int = 3
@export
var active_reload_rim_length: int = 10
#endregion

var disabled: bool = false

enum ActiveReloadResult {FAIL, GOOD, PERFECT}

signal bullets_changed
signal reload_started
signal reload_complete
signal active_reload_success(num)
signal shot_bullet(count)
signal activated


func _ready() -> void:
	state_machine.init(self)
	
	reload_timer = ScalableTimer.new()
	reload_timer.one_shot = true
	add_child(reload_timer)
	
	update_aim_cone()
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	
	point_aim_cone_at(get_local_mouse_position())
	
func set_color(color: Color) -> void:
	weapon_color = color
	queued_color = weapon_color.lightened(0.4)
	aim_cone.color = Color(weapon_color, 0.2)
	attack_cone.color = weapon_color
	attack_full_cone.color = background_color
	
func _unhandled_input(event: InputEvent) -> void:
	if selected:
		state_machine.process_input(event)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func update_aim_cone() -> void:
	var spread: float = weapon_data.get_spread_in_rad()
	aim_cone.polygon = cone_from_angle(spread, 100000)
	attack_full_cone.polygon = cone_from_angle(spread, 100000)
	
func update_attack_cone(progress: float) -> void:
	attack_cone.polygon = cone_from_angle(weapon_data.get_spread_in_rad() * progress, 100000)
	
func cone_from_angle(angle: float, radius: float) -> PackedVector2Array:
	# calculate three points of triangle
	var cone = []
	cone.append(Vector2(100,0))
	cone.append(Vector2.from_angle(angle/2) * radius)
	cone.append(Vector2.from_angle(-angle/2) * radius)
	return cone

func get_queued_attack_count() -> int:
	return attack_direction_queue.size()

func has_bullets() -> bool:
	return bullets.size() > 0
func has_queued_bullets() -> bool:
	return !queued_bullets.is_empty()
func magazine_empty() -> bool:
	return !has_bullets() and !has_queued_bullets()
	
func reload() -> void:
	clear_bullets()
	print("reloaded " + weapon_data.equipment_name + " " + str(bullets.size()) + "/" + str(magazine_size))
	bullets = Gun.bullet_generator.generate_bullets(magazine_size)
	
	active_reload_available = true
	reload_sfx.stream = weapon_data.reload_sound
	reload_sfx.play()
	
	bullets_changed.emit()
	reload_complete.emit()

func clear_bullets() -> void:
	print("removed " + str(bullets.size()) + " bullets")
	bullets.clear()
	queued_bullets.clear()

func fill_bullets() -> void:
	bullets.clear()
	bullets = Gun.bullet_generator.generate_bullets(magazine_size)
	active_reload_available = true
	reload_sfx.stream = weapon_data.reload_sound
	reload_sfx.play()
	bullets_changed.emit()
	reload_complete.emit()
	
func get_magazine_status() -> String:
	var queued_count: int = get_queued_attack_count()
	var output = ""
	
	output += str(bullets.size() - queued_count)
	#output += "(" + str(queued_count) + ")"
	output += " / " + str(magazine_size)
	
	return output
	
func on_activation(dir: Vector2) -> void:
	var current_bullet: Bullet = queued_bullets.pop_front()
	current_bullet.piercing = all_bullets_penetrate
	current_bullet.damage_amount = weapon_data.damage_amount
	
	for i in range(current_bullet.projectile_count):
		# make new projectile
		var new_bullet: Projectile = weapon_data.projectile_scene.instantiate()
			
		var random_spread_offset: float = randf_range(-weapon_data.get_spread_in_rad()/2, weapon_data.get_spread_in_rad()/2)
		# set stats
		# save origin unit to call back for experience gain
		new_bullet.origin_unit = get_parent()
		new_bullet.launch(
			dir.normalized().rotated(random_spread_offset * (current_bullet.projectile_count)), 
			get_projectile_speed(), 
			int(current_bullet.damage_amount / float(current_bullet.projectile_count)), 
			weapon_data.knock_back_force)
		new_bullet.global_position = muzzle_point.global_position
		
		new_bullet.bullet_data = current_bullet
		if current_bullet.piercing:
			new_bullet.pierce_count += 1
		
		# add to scene
		get_tree().root.get_node("Game").projectiles.add_child(new_bullet)
	
	CameraControl.camera.shake_screen(20,200)
	
func point_arm_at(target_pos: Vector2) -> void:
	var angle: float = Vector2.RIGHT.angle_to_point(target_pos)
	arm.rotation = angle
	var hand: Sprite2D = arm.get_node("Node2D/Hand")
	# flip v if hand is on the left side
	hand.flip_v = (hand.global_position - global_position).x <= 0
	
func point_aim_cone_at(target_pos: Vector2) -> void:
	var angle: float = Vector2.RIGHT.angle_to_point(target_pos)
	aim_cone.rotation = angle

func clear_attack_queues():
	attack_direction_queue.clear()
	for item in queued_attack_cones:
		item.queue_free()
	queued_attack_cones.clear()

func reset() -> void:
	clear_attack_queues()
	attack_full_cone.visible = false
	reload_timer.stop()
	
# check active reload success
func check_active_reload_success() -> bool:
	var timer: ScalableTimer = reload_timer
	if timer.is_stopped():
		return false
	
	# determine active reload success
	match inside_active_reload_range():
		ActiveReloadResult.PERFECT:
			print("active reload success!")
			timer.stop()
			timer.timeout.emit()
			active_reload_sound_player.stream = active_reload_success_sound
			active_reload_sound_player.play()
			active_reload_available = false
			
			active_reload_success.emit()
			return true
		ActiveReloadResult.GOOD:
			print("active reload kinda success...")
			timer.speed = 2.5
			active_reload_sound_player.stream = active_reload_success_sound
			active_reload_sound_player.play()
			active_reload_available = false
			
			active_reload_success.emit()
			return true
		_:
			print("active reload fail!")
			active_reload_sound_player.stream = active_reload_fail_sound
			active_reload_sound_player.play()
			active_reload_failed = true
			active_reload_available = false
		
			return false

func inside_active_reload_range() -> int:
	if reload_timer.is_stopped():
		return false
	var selected_point: float = (1 - reload_timer.time_left / reload_timer.max_time) * 100
	
	#print("perfect range: " + str(active_reload_range))
	#print("good range: " + str(active_reload_range + Vector2i(-active_reload_rim_length, active_reload_rim_length)))
	#print("current point: " + str(selected_point))
	
	if !active_reload_available:
		return false
	if active_reload_range.x < selected_point and selected_point < active_reload_range.y:
		return ActiveReloadResult.PERFECT
	elif active_reload_range.x < selected_point and selected_point < active_reload_range.y + active_reload_rim_length:
		return ActiveReloadResult.GOOD
	else:
		return ActiveReloadResult.FAIL

func get_reload_time() -> float:
	return weapon_data.reload_time * get_parent().stat_component.reload_time_modifier
	
func get_aim_time_modifier() -> float:
	return get_parent().stat_component.aim_time_modifier

func get_projectile_speed() -> float:
	return min(weapon_data.projectile_speed * get_parent().stat_component.projectile_speed_modifier, WeaponComponent.projectile_max_speed)
