extends RigidBody2D
class_name EnemyUnit

static var core_position: Vector2

var health_points: int = 100

var movement_speed: float = 0

var adjust_modifier: float = 8
var speed_adjust_modifier: float = 4

@onready
var health_label: Label = $HealthLabel

@onready
var sprite: Sprite2D = $Sprite2D/Sprite2D

var death_effect = preload("res://Scenes/death_effect.tscn")


func on_spawn(speed: float, health: int) -> void:
	var core_dir = global_position.direction_to(EnemyUnit.core_position)
	apply_central_impulse(core_dir * speed)
	health_points = health
	movement_speed = speed

func _ready():
	health_label.text = str(health_points)
	
func receive_hit(damage_amount: int):
	health_points -= damage_amount
	health_label.text = str(health_points)
	print("Received damage: " + str(damage_amount))
	if health_points <= 0:
		var new_effect: CPUParticles2D = death_effect.instantiate()
		new_effect.global_position = global_position
		get_tree().root.add_child(new_effect)
		get_parent().remove_child(self)
		queue_free()
	$Sprite2D/AnimationPlayer.play("hit_animation")

func _physics_process(delta):
	# adjust velocity to go towards core
	var current_direction: Vector2 = linear_velocity.normalized()
	var current_speed: float = linear_velocity.length()
	
	var target_direction: Vector2 = global_position.direction_to(core_position)
	
	var adjustment_force: Vector2 = target_direction - current_direction
	
	apply_central_impulse(adjustment_force * adjust_modifier)
	
	# bring speed back to normal
	if current_speed > movement_speed:
		apply_central_impulse(abs(current_speed - movement_speed) * -current_direction * delta)
	else:
		apply_central_impulse(abs(current_speed - movement_speed) * speed_adjust_modifier * current_direction * delta)
	
	# flip sprite based on movement
	# right is false
	sprite.flip_h = linear_velocity.x <= 0
