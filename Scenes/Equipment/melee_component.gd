extends Area2D
class_name MeleeWeaponComponent

var game_ref: Game

var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()
@export
var auto: bool = true
@export
var disabled: bool = false

## Which action using this weapon is bound to
@export
var light_attack_action_name: String
@export
var heavy_attack_action_name: String

@export
var radius: float = 400
@export
var crit_radius: float = 250
@onready
var crit_area: Area2D = $CritArea

var last_attack_light: bool = false
@export
var light_attack_angle: float = PI / 3
@export
var light_attack_cooldown: float = 0.7
@export
var heavy_attack_cooldown: float = 1.7
var light_attack_cooldown_timer: Timer
var heavy_attack_cooldown_timer: Timer

@export
var damage_amount: int = 1
@export
var knock_back_amount: float = 1000

@onready
var light_attack_sound: AudioStreamPlayer = $LightAttackSound
@onready
var heavy_attack_sound: AudioStreamPlayer = $HeavyAttackSound

var exit_effect: PackedScene = preload("res://Scenes/enemy_hit_effect.tscn")


func _ready() -> void:
	set_range(radius, crit_radius)
	queue_redraw()
	
	# make melee timer
	light_attack_cooldown_timer = Timer.new()
	light_attack_cooldown_timer.autostart = false
	light_attack_cooldown_timer.one_shot = true
	add_child(light_attack_cooldown_timer)
	
	heavy_attack_cooldown_timer = Timer.new()
	heavy_attack_cooldown_timer.autostart = false
	heavy_attack_cooldown_timer.one_shot = true
	add_child(heavy_attack_cooldown_timer)

func set_range(new_rad: float, new_crit_rad: float) -> void:
	$CollisionShape2D.shape.set_radius(new_rad)
	$CritArea/CollisionShape2D.shape.set_radius(new_crit_rad)

# draw attack range
func _draw() -> void:
	if selected:
		var light_cooldown_ratio: float = (light_attack_cooldown_timer.time_left) / light_attack_cooldown_timer.wait_time
		var heavy_cooldown_ratio: float = (heavy_attack_cooldown_timer.time_left) / heavy_attack_cooldown_timer.wait_time
		# slowly turn solid with cooldown. Ready equals alpha 1
		var mouse_angle: float = get_local_mouse_position().angle()
		draw_arc(Vector2.ZERO, radius, 0, 2 * PI, 32, Color(Color.WHITE, 1 - heavy_cooldown_ratio ), 10, true)
		draw_arc(Vector2.ZERO, crit_radius, 0, 2 * PI, 32, Color(Color.ORANGE, 1 - heavy_cooldown_ratio ), 10, true)
		
		draw_arc(Vector2.ZERO, (radius + crit_radius) / 2, mouse_angle - light_attack_angle/2, mouse_angle + light_attack_angle/2, 32, Color(Color.WHITE, min(1 - light_cooldown_ratio, 0.5)), (radius + crit_radius) / 4, true)
		draw_arc(Vector2.ZERO, crit_radius / 2, mouse_angle - light_attack_angle/2, mouse_angle + light_attack_angle/2, 32, Color(Color.DARK_ORANGE, min(1 - light_cooldown_ratio, 0.5)), crit_radius, true)
		#draw_arc(Vector2.ZERO, crit_radius, mouse_angle - light_attack_angle/2, mouse_angle + light_attack_angle/2, 32, Color(Color.DARK_ORANGE, 1 - light_cooldown_ratio ), 50, true)
			
func _physics_process(_delta: float) -> void:
	if disabled:
		return
		
	if auto and selected:
		if heavy_attack_cooldown_timer.is_stopped():
			# melee attack
			var targets = get_overlapping_bodies()
			if !targets.is_empty():
				activate_heavy()
	#if !melee_cooldown_timer.is_stopped():
	queue_redraw()

func _unhandled_input(_event: InputEvent) -> void:
	if disabled:
		return
		
	if !auto and selected:
		if Input.is_action_pressed(light_attack_action_name):
			activate_light()
		if Input.is_action_pressed(heavy_attack_action_name):
			activate_heavy()
		
func activate_heavy() -> void:
	if !heavy_attack_cooldown_timer.is_stopped():
		return
		
	var targets = get_overlapping_bodies()
	var crits = crit_area.get_overlapping_bodies()
	for item in targets:
		if item is EnemyUnit:
			item.receive_hit(damage_amount, item in crits, global_position.direction_to(item.global_position))
			item.apply_central_impulse(global_position.direction_to(item.global_position).normalized() * knock_back_amount)
			# blood effect
			var new_exit_eff: Node2D = exit_effect.instantiate()
			new_exit_eff.global_position = item.global_position
			new_exit_eff.rotation = global_position.direction_to(item.global_position).angle()
			new_exit_eff.get_node("CPUParticles2D").emitting = true
			get_tree().root.add_child(new_exit_eff)
			
	heavy_attack_cooldown_timer.start(heavy_attack_cooldown)
	heavy_attack_sound.play(0.1)
	
	last_attack_light = false
	
	if game_ref:
		CameraControl.camera.shake_screen(50,175)
	
func activate_light() -> void:
	if !light_attack_cooldown_timer.is_stopped():
		return
		
	var mouse_angle: float = get_local_mouse_position().angle()
	var starting: float = mouse_angle - light_attack_angle/2
	var ending: float = mouse_angle + light_attack_angle/2
	
	var targets = get_overlapping_bodies()
	var crits = crit_area.get_overlapping_bodies()
	for item in targets:
		if item is EnemyUnit:
			var enemy_angle: float = global_position.direction_to(item.global_position).angle()
			if starting < enemy_angle + PI/9 and enemy_angle < ending + PI/9:
				item.receive_hit(damage_amount, item in crits, global_position.direction_to(item.global_position))
				item.apply_central_impulse(global_position.direction_to(item.global_position).normalized() * knock_back_amount)
			
				# blood effect
				var new_exit_eff: Node2D = exit_effect.instantiate()
				new_exit_eff.global_position = item.global_position
				new_exit_eff.rotation = enemy_angle
				new_exit_eff.get_node("CPUParticles2D").emitting = true
				get_tree().root.add_child(new_exit_eff)
			
	light_attack_cooldown_timer.start(light_attack_cooldown)
	light_attack_sound.play(0.1)
	
	get_parent().apply_central_impulse(get_local_mouse_position().normalized() * 1000)
	
	last_attack_light = true
			
	if game_ref:
		CameraControl.camera.shake_screen(30,200)
