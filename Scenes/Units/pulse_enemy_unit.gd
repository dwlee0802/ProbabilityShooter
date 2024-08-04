extends EnemyUnit

@onready
var movement_timer: Timer = $MovementTimer
@export
var impulse: float = 500

func _ready():
	super._ready()
	## random offset to movement timer
	await get_tree().create_timer(randf_range(0, 2)).timeout
	movement_timer.start(3)
	movement_timer.timeout.connect(apply_movement)
	
func on_spawn(speed: float, health: int) -> void:
	health_points = health
	impulse = speed * 10
	health_bar = $HealthBar
	health_bar.set_max(health)
	health_bar.change_value(health, true)

func _physics_process(_delta):
	return
	
func apply_movement():
	# adjust velocity to go towards core
	var target_direction: Vector2 = global_position.direction_to(core_position)
	
	apply_central_impulse(target_direction * impulse)
	
	# flip sprite based on movement
	# right is false
	sprite.flip_h = linear_velocity.x <= 0
