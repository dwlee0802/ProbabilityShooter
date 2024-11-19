extends Area2D
class_name MeleeWeaponComponent

@export
var radius: float = 0
var melee_cooldown: float = 1.0
var melee_cooldown_timer: Timer

@export
var damage_amount: int = 1


func _ready() -> void:
	set_range(radius)
	queue_redraw()
	
	# make melee timer
	melee_cooldown_timer = Timer.new()
	melee_cooldown_timer.autostart = false
	melee_cooldown_timer.one_shot = true
	add_child(melee_cooldown_timer)

func set_range(new_rad: float) -> void:
	$CollisionShape2D.shape.set_radius(new_rad)

# draw attack range
func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, 2 * PI, 32, Color.WHITE, 10, true)

func _physics_process(_delta: float) -> void:
	if melee_cooldown_timer.is_stopped():
		# melee attack
		var targets = get_overlapping_bodies()
		if !targets.is_empty():
			for item in targets:
				if item is EnemyUnit:
					item.receive_hit(damage_amount)
			melee_cooldown_timer.start(melee_cooldown)
