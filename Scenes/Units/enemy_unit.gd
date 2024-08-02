extends RigidBody2D
class_name EnemyUnit

static var core_position: Vector2

var health_points: float = 100

## percentage of radius that is considered a critical hit
var critical_hit_ratio: float = 0.2

var movement_speed: float = 0
var movement_speed_modifier: float = 0
var movement_speed_multiplier: float = 1.0

var adjust_modifier: float = 8
var speed_adjust_modifier: float = 4

@onready
var health_label: Label = $HealthLabel
var health_bar: DelayedProgressBar

@onready
var sprite: Sprite2D = $Sprite2D/Sprite2D

var death_effect = preload("res://Scenes/Units/death_effect.tscn")
var damage_popup = preload("res://Scenes/damage_popup.tscn")

signal on_death


func on_spawn(speed: float, health: int) -> void:
	var core_dir = global_position.direction_to(EnemyUnit.core_position)
	apply_central_impulse(core_dir * speed)
	health_points = health
	movement_speed = speed
	health_bar = $HealthBar
	health_bar.set_max(health)
	health_bar.change_value(health, true)

func _ready():
	health_label.text = str(health_points)
	
func receive_hit(damage_amount: float, critical: bool = false):
	if critical:
		$CritArea/Sprite2D2/AnimationPlayer.play("crit_hit_animation")
		damage_amount *= 2
		
	health_points -= damage_amount
	health_bar.change_value(int(health_points))
	health_label.text = str(int(health_points))
	#print("Received damage: " + str(damage_amount))
	
	var new_popup = damage_popup.instantiate()
	new_popup.set_label(str(int(damage_amount)))
	new_popup.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	get_tree().root.add_child(new_popup)
	
	if health_points <= 0:
		die()
	$Sprite2D/AnimationPlayer.play("hit_animation")

func die():
	var new_effect: CPUParticles2D = death_effect.instantiate()
	new_effect.global_position = global_position
	get_tree().root.add_child(new_effect)
	get_parent().remove_child(self)
	on_death.emit()
	queue_free()
	
func _physics_process(delta):
	# adjust velocity to go towards core
	var current_direction: Vector2 = linear_velocity.normalized()
	var current_speed: float = linear_velocity.length()
	
	var target_direction: Vector2 = global_position.direction_to(core_position)
	
	var adjustment_force: Vector2 = target_direction - current_direction
	
	apply_central_impulse(adjustment_force * adjust_modifier)
	
	# bring speed back to normal
	if current_speed > get_movement_speed():
		apply_central_impulse(abs(current_speed - get_movement_speed()) * -current_direction * speed_adjust_modifier * delta)
	else:
		apply_central_impulse(abs(current_speed - get_movement_speed()) * speed_adjust_modifier * current_direction * delta)
	
	# flip sprite based on movement
	# right is false
	sprite.flip_h = linear_velocity.x <= 0

func get_movement_speed() -> float:
	return movement_speed * movement_speed_multiplier + movement_speed_modifier

## determines if the received hit is a critical hit
## a hit is critical when its trajectory line's shortest distance from the center is smaller than crit hit range
## can get that number by multiplying radius with sin(bullet direction and hit direction)
func determine_critical_hit(bullet_dir: Vector2, hit_pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(hit_pos, hit_pos + bullet_dir.normalized() * 100)
	var result = space_state.intersect_ray(query)
	print(result)
	return !result.is_empty()
