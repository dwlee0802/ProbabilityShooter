extends Shootable

@onready
var area: Area2D = $Area2D

@export
var damage_range: Vector2 = Vector2(0, 500)

@onready
var explosion_animation: AnimationPlayer = $ExplosionEffect/AnimationPlayer


func activate() -> void:
	super.activate()
	await get_tree().create_timer(0.1).timeout
	
	explosion_animation.play("explosion_animation")
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	var bodies = area.get_overlapping_bodies()
	for unit in bodies:
		if unit is EnemyUnit:
			# damage stuff inside range
			unit.receive_hit(500, false)
			
			# apply knock back
			unit.apply_impulse(global_position.direction_to(unit.global_position) * 800)
		
		# chain reaction
		if unit is Shootable and unit != self and !unit.activated:
			unit.activate()
			
	# screen shake
	CameraControl.camera.shake_screen(40,200)
	
	# destroy self
	await explosion_animation.animation_finished
	
	queue_free()
	
	return
