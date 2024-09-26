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
var lifetime_limit: float = 10

var on_hit_effect = preload("res://Scenes/projectile_hit_effect.tscn")

var exit_effect = preload("res://Scenes/enemy_hit_effect.tscn")

var smoke_effect = preload("res://Scenes/Effects/smoke_particle.tscn")

var dynamite_scene = load("res://Scenes/Shootables/dynamite.tscn")

var penetration_probability: float = 0

var bullet_data: Bullet

@export
var spawn_after: PackedScene

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
	
func _physics_process(delta):
	position += velocity * delta
	lifetime += delta
	if lifetime_limit < lifetime:
		queue_free()

# hit something
func _on_body_entered(body) -> void:
	## ignore collision if shot from ally
	if body is EnemyUnit and !is_player:
		return
	if body is PlayerUnit and is_player:
		return
		
	if body is EnemyUnit and is_player:
		# apply damage
		var eff_dmg: int = body.receive_hit(damage_amount, body.determine_critical_hit(dir, global_position), dir)
		# apply knock-back
		body.apply_central_impulse(dir.normalized() * knock_back_amount)
		# give exp to shooter
		if origin_unit is PlayerUnit:
			origin_unit.add_experience(eff_dmg)
	
		var new_eff: Node2D = on_hit_effect.instantiate()
		new_eff.global_position = global_position
		new_eff.rotation = dir.angle()
		new_eff.get_node("CPUParticles2D").emitting = true
		get_tree().root.add_child(new_eff)
		
		var new_exit_eff: Node2D = exit_effect.instantiate()
		new_exit_eff.global_position = global_position
		new_exit_eff.rotation = dir.angle()
		new_exit_eff.get_node("CPUParticles2D").emitting = true
		get_tree().root.add_child(new_exit_eff)
		
		if !bullet_data.piercing:
			return
	
	if body is PlayerUnit and !is_player:
		body.receive_hit(damage_amount)
		
	if body is Shootable:
		body.activate()
	
	if bullet_data.explosive:
		var new_dynamite: Shootable = dynamite_scene.instantiate()
		new_dynamite.get_node("CollisionShape2D").disabled = true
		get_tree().root.call_deferred("add_child", new_dynamite)
		new_dynamite.global_position = global_position
		new_dynamite.radius = 500
		new_dynamite.damage_amount = damage_amount
		new_dynamite.call_deferred("activate")
		new_dynamite.shooter = origin_unit
	
	queue_free()
