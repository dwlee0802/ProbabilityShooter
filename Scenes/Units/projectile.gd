extends Area2D
class_name Projectile

var dir: Vector2
var speed: float

var damage_amount: int = 0

var knock_back_amount: float = 800

var lifetime: float = 0
# deletes self after this time
var lifetime_limit: float = 10

var on_hit_effect = preload("res://Scenes/projectile_hit_effect.tscn")

var exit_effect = preload("res://Scenes/enemy_hit_effect.tscn")

var smoke_effect = preload("res://Scenes/Effects/smoke_particle.tscn")


func launch(direction: Vector2, _speed: float, amount: int, _knock_back: float = 0) -> void:
	knock_back_amount = _knock_back
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
	position += delta * speed * dir
	lifetime += delta
	if lifetime_limit < lifetime:
		queue_free()

# hit something
func _on_body_entered(body) -> void:
	if body is EnemyUnit:
		# apply damage
		body.receive_hit(damage_amount, body.determine_critical_hit(dir, global_position), self)
		# apply knock-back
		body.apply_central_impulse(dir.normalized() * knock_back_amount)
	
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
	
	queue_free()
