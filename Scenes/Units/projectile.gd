extends Area2D
class_name Projectile

var origin_unit

var is_player: bool = true

var dir: Vector2
var speed: float

var velocity: Vector2 = Vector2.ZERO

var damage_amount: int = 0

var knock_back_amount: float = 800

var lifetime: float = 0
# deletes self after this time
var lifetime_limit: float = 1.5

var dynamite_scene = load("res://Scenes/Shootables/dynamite.tscn")

var heal_orb_scene: PackedScene = preload("res://Scenes/health_orb.tscn")

var penetration_probability: float = 0

var bullet_data: Bullet

var smoke_effect: PackedScene = preload("res://Scenes/Effects/smoke_particle.tscn")
var on_hit_effect: PackedScene = preload("res://Scenes/projectile_hit_effect.tscn")
var exit_effect: PackedScene = preload("res://Scenes/enemy_hit_effect.tscn")
@export
var spawn_after: PackedScene

@onready
var line_effect: Line2D = $Line2D
@onready
var start_location: Vector2 = Vector2.ZERO

var pierce_count: int = 0


func launch(direction: Vector2, _speed: float, amount: int, _knock_back: float = 0) -> void:
	knock_back_amount = _knock_back
	velocity = direction.normalized() * _speed
	dir = direction
	speed = _speed
	damage_amount = amount
	
func _ready():
	var new_smoke_eff: CPUParticles2D = smoke_effect.instantiate()
	new_smoke_eff.direction = dir.normalized()
	new_smoke_eff.global_position = global_position
	new_smoke_eff.emitting = true
	get_tree().root.add_child(new_smoke_eff)
	start_location = global_position
	
func _physics_process(delta):
	position += velocity * delta
	lifetime += delta
	
	# line effect
	line_effect.set_point_position(1, start_location - global_position)
	
	if lifetime_limit < lifetime:
		queue_free_self()

# hit something
func _on_body_entered(body) -> void:
	## ignore collision if shot from ally
	if body is EnemyUnit and !is_player:
		return
	if body is PlayerUnit and is_player:
		return
		
	if body is EnemyUnit and is_player:
		UpgradesManager.process_event(Event.new(self, global_position, body, Event.EventCode.PROJECTILE_HIT))
		
		if body.is_full_health():
			UpgradesManager.process_event(Event.new(self, global_position, body, Event.EventCode.PROJECTILE_HIT_FULL_HP))
		
		if body.shield and !bullet_data.piercing:
			body.receive_hit(damage_amount, body.determine_critical_hit(dir, global_position), dir)
			queue_free_self()
		else:
			# apply damage
			body.receive_hit(damage_amount, body.determine_critical_hit(dir, global_position), dir, bullet_data)
				
			# apply knock-back
			body.apply_central_impulse(dir.normalized() * knock_back_amount)
			## give exp to shooter
			#if origin_unit is PlayerUnit:
				#origin_unit.add_experience(eff_dmg)
		
			var new_eff: Node2D = on_hit_effect.instantiate()
			new_eff.global_position = global_position
			new_eff.rotation = dir.angle()
			new_eff.get_node("CPUParticles2D").emitting = true
			if body.determine_critical_hit(dir, global_position):
				new_eff.critical()
				UpgradesManager.process_event(Event.new(self, global_position, body, Event.EventCode.PROJECTILE_CRIT))
		
			# apply burn
			if bullet_data.fire:
				body.apply_burning()
				
			get_tree().root.add_child(new_eff)
			
			var new_exit_eff: Node2D = exit_effect.instantiate()
			new_exit_eff.global_position = global_position
			new_exit_eff.rotation = dir.angle()
			new_exit_eff.get_node("CPUParticles2D").emitting = true
			get_tree().root.add_child(new_exit_eff)
		
		if body.is_dead():
			UpgradesManager.process_event(Event.new(self, global_position, body, Event.EventCode.PROJECTILE_KILL))
			
	if body is PlayerUnit and !is_player:
		body.receive_hit(damage_amount)
		queue_free_self()
		
	if body is Shootable:
		body.shooter = origin_unit
		body.activate()
	
	#if bullet_data.explosive:
		#var new_dynamite: Shootable = dynamite_scene.instantiate()
		#new_dynamite.get_node("CollisionShape2D").disabled = true
		#get_tree().root.call_deferred("add_child", new_dynamite)
		#new_dynamite.global_position = global_position
		#new_dynamite.radius = 500
		#new_dynamite.damage_amount = damage_amount
		#new_dynamite.call_deferred("activate")
		#new_dynamite.shooter = origin_unit
	
	if pierce_count > 0:
		pierce_count -= 1
		return
	else:
		queue_free_self()
		
func queue_free_self() -> void:
	line_effect.reparent(get_tree().root)
	line_effect.get_node("AnimationPlayer").play("fade_out")
	queue_free()
