extends RigidBody2D
class_name Spaceship

## Physics Parameters
@export
var speed_max: float = 300
var speed: float = 0
var acceleration: float = 10
@export
var thrust_force: float = 100
@export
var after_burner_multiplier: float = 3

@export
var angular_max: float = 10
var angular_acceleration: float = 5

## Ship Body
@onready
var ship_body: Node2D = $ShipBody
@onready
var flame_sprite: Sprite2D = $ShipBody/FlameSprite
@onready
var afterburner_sprite: Sprite2D = $ShipBody/AfterburnerSprite
@onready
var flame_particles: CPUParticles2D = $ShipBody/FlameParticles

## attacking 
@onready
var turrets: Node2D = $ShipBody/Turrets
var projectile_scene: PackedScene = preload("res://Scenes/Units/projectile.tscn")

var queued_attack_cones = []
var attack_direction_queue = []
@onready
var attack_cooldown: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_ignite_thrusters(delta)
	_rotate_ship(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed("action_one"):
		# save mouse position and start attack timer
		for turret: Turret in turrets.get_children():
			if turret.aim_timer.is_stopped():
				turret.start_attack_process()
		return
	
func _ignite_thrusters(_delta: float) -> void:
	flame_sprite.visible = false
	flame_particles.emitting = false
	afterburner_sprite.visible = false
	if Input.is_action_pressed("forward"):
		var dir: Vector2 = Vector2.from_angle(ship_body.rotation)
		if Input.is_action_pressed("after_burner"):
			apply_central_impulse(dir * thrust_force * after_burner_multiplier)
			afterburner_sprite.visible = true
		else:
			apply_central_impulse(dir * thrust_force)
			
		flame_sprite.visible = true
		flame_particles.emitting = true
	
func _rotate_ship(delta: float) -> void:
	# rotate sprite
	# make this physics based?
	if Input.is_action_pressed("rotate_right"):
		ship_body.rotate(angular_acceleration * delta)
	if Input.is_action_pressed("rotate_left"):
		ship_body.rotate(-angular_acceleration * delta)
