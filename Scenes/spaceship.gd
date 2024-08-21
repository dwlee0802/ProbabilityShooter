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

var projectile_scene: PackedScene = preload("res://Scenes/Units/projectile.tscn")

@onready
var aim_cone: Polygon2D = $AimCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_aim_cone()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_ignite_thrusters(delta)
	_rotate_ship(delta)
	
	aim_cone.rotation = Vector2.ZERO.angle_to_point(get_local_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed("action_one"):
		# save mouse position and start attack timer
		var new_projectile: Projectile = projectile_scene.instantiate()
		new_projectile.global_position = global_position
		get_tree().root.add_child(new_projectile)
		new_projectile.launch(Vector2.from_angle(ship_body.rotation), 1000, 100, 100)
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

func update_aim_cone() -> void:
	var spread: float = 0.1
	aim_cone.polygon = cone_from_angle(spread, 100000)
	attack_full_cone.polygon = cone_from_angle(spread, 100000)
	aim_cone.rotation = Vector2.ZERO.angle_to_point(get_local_mouse_position())
	
func cone_from_angle(angle: float, radius: float) -> PackedVector2Array:
	# calculate three points of triangle
	var cone = []
	cone.append(Vector2.ZERO)
	cone.append(Vector2.from_angle(angle/2) * radius)
	cone.append(Vector2.from_angle(-angle/2) * radius)
	return cone
