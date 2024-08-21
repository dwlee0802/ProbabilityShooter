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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	
	# rotate sprite
	# make this physics based?
	if Input.is_action_pressed("rotate_right"):
		ship_body.rotate(angular_acceleration * delta)
	if Input.is_action_pressed("rotate_left"):
		ship_body.rotate(-angular_acceleration * delta)
			
