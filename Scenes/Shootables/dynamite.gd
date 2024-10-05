extends Shootable
class_name Explosive

var shooter

@onready
var area: Area2D = $Area2D

@export
var damage_amount: int = 1

@onready
var explosion_animation: AnimationPlayer = $ExplosionEffect/AnimationPlayer
@onready
var explosion_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export
var radius: float = 1500

func _ready() -> void:
	set_size(radius)
	
func activate() -> void:
	super.activate()
	await get_tree().create_timer(0.1).timeout
	
	explosion_animation.play("explosion_animation")
	explosion_sound.play()
	
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	var bodies = area.get_overlapping_bodies()
	#print("COUNT: " + str(bodies.size()))
	for unit in bodies:
		if unit is EnemyUnit and unit.health_points > 0 and unit.is_node_ready():
			var dir: Vector2 = global_position.direction_to(unit.global_position)
			# damage stuff inside range
			#if shooter != null and shooter is PlayerUnit:
				#shooter.add_experience(int(unit.receive_hit(damage_amount, true, dir) * 0.5))
			#else:
			unit.receive_hit(damage_amount, false, dir)
				
			# apply knock back
			unit.apply_impulse(dir * 1000)
		
		# chain reaction
		if unit is Shootable and unit != self and !unit.activated:
			unit.activate()
	
	var areas = area.get_overlapping_areas()
	for item in areas:
		if item is Projectile and !item.is_player:
			item.queue_free()
			
	# screen shake
	CameraControl.camera.shake_screen(40,200)
	
	# destroy self
	await explosion_animation.animation_finished
	
	queue_free()
	
	return

func set_size(new_radius: float) -> void:
	$ExplosionEffect/Sprite2D.scale = Vector2(new_radius/243, new_radius/243)
	$Area2D/CollisionShape2D.shape.set_radius(new_radius)
