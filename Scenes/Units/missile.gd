extends RigidBody2D
class_name Missile

@export
var game_ref: Node

var target: Node2D

var initial_thrust: float = 100

var thrust: float = 50

var dynamite_scene = load("res://Scenes/Shootables/dynamite.tscn")

var explosion_range: float = 100

@onready
var target_line: Line2D = $Line2D
@onready
var target_crosshair: Sprite2D = $TargetSprite

@onready
var smoke_particles: CPUParticles2D = $SmokeParticle

@onready
var launch_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	apply_central_impulse(Vector2.from_angle(randf_range(0, TAU)) * initial_thrust)
	smoke_particles.emitting = true
	launch_sound.play()

func _physics_process(_delta: float) -> void:
	if target and is_instance_valid(target) and target is EnemyUnit and !target.is_dead():
		# otherwise apply force towards the target
		apply_central_impulse(global_position.direction_to(target.global_position) * thrust)
		var target_dir: Vector2 = target.global_position - global_position
		#if target_dir.length() < 200:
			#target_line.set_point_position(1, target_dir)
		#else:
			#target_line.set_point_position(1, target_dir.normalized() * 250)
		#target_line.visible = true
		if !target_crosshair.visible:
			target_crosshair.visible = true
		target_crosshair.global_position = target.global_position
	else:
		var candidates = game_ref.enemies.get_children()
		if candidates.size() >= 1:
			target = candidates.pick_random()
		apply_central_impulse(linear_velocity.normalized() * thrust)
		#target_line.visible = false
		target_crosshair.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is EnemyUnit:
		var new_dynamite: Shootable = dynamite_scene.instantiate()
		new_dynamite.get_node("CollisionShape2D").disabled = true
		game_ref.call_deferred("add_child", new_dynamite)
		
		new_dynamite.global_position = global_position
		new_dynamite.radius = explosion_range
		new_dynamite.damage_amount = 1
		
		new_dynamite.call_deferred("activate")
		
	queue_free()

func _on_lifetime_timer_timeout() -> void:
	_on_body_entered(EnemyUnit.new())
