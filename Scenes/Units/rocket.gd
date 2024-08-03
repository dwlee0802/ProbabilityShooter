extends Projectile
class_name Rocket

@onready
var explosion_area: Area2D = $ExplosionArea


func _physics_process(delta):
	super._physics_process(delta)
	speed += delta * 2000
		
# hit something
func _on_body_entered(_body) -> void:
	var enemies = explosion_area.get_overlapping_bodies()
	
	$ExplosionSprite.visible = true
	
	for unit in enemies:
		if unit is EnemyUnit:
			# apply damage
			unit.receive_hit(damage_amount, unit.determine_critical_hit(dir, global_position))
			# apply knock-back
			unit.apply_central_impulse(dir.normalized() * knock_back_amount)
	
	dir = Vector2.ZERO
	
	await get_tree().create_timer(0.1).timeout
	
	$ExplosionSprite.visible = false
	queue_free()
