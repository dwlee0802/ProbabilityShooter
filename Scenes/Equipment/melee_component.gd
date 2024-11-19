extends Area2D
class_name MeleeWeaponComponent

var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()
@export
var auto: bool = true

## Which action using this weapon is bound to
@export
var action_name: String

@export
var radius: float = 400
@export
var crit_radius: float = 250
@onready
var crit_area: Area2D = $CritArea

@export
var melee_cooldown: float = 1.0
var melee_cooldown_timer: Timer

@export
var damage_amount: int = 1
@export
var knock_back_amount: float = 1000

@onready
var attack_sound: AudioStreamPlayer = $AttackSound


func _ready() -> void:
	set_range(radius, crit_radius)
	queue_redraw()
	
	# make melee timer
	melee_cooldown_timer = Timer.new()
	melee_cooldown_timer.autostart = false
	melee_cooldown_timer.one_shot = true
	add_child(melee_cooldown_timer)

func set_range(new_rad: float, new_crit_rad: float) -> void:
	$CollisionShape2D.shape.set_radius(new_rad)
	$CritArea/CollisionShape2D.shape.set_radius(new_crit_rad)

# draw attack range
func _draw() -> void:
	if selected:
		var melee_cooldown_ratio: float = (melee_cooldown_timer.time_left) / melee_cooldown
		# slowly turn solid with cooldown. Ready equals alpha 1
		draw_arc(Vector2.ZERO, radius, 0, 2 * PI, 32, Color(Color.WHITE, 1 - melee_cooldown_ratio ), 10, true)
		draw_arc(Vector2.ZERO, crit_radius, 0, 2 * PI, 32, Color(Color.ORANGE, 1 - melee_cooldown_ratio ), 10, true)

func _physics_process(_delta: float) -> void:
	if auto and selected:
		if melee_cooldown_timer.is_stopped():
			# melee attack
			var targets = get_overlapping_bodies()
			if !targets.is_empty():
				activate()
	if !melee_cooldown_timer.is_stopped():
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if !auto and selected:
		if Input.is_action_pressed(action_name):
			activate()
		
func activate() -> void:
	if !melee_cooldown_timer.is_stopped():
		return
		
	var targets = get_overlapping_bodies()
	var crits = crit_area.get_overlapping_bodies()
	for item in targets:
		if item is EnemyUnit:
			item.receive_hit(damage_amount, item in crits)
			item.apply_central_impulse(global_position.direction_to(item.global_position).normalized() * knock_back_amount)
	melee_cooldown_timer.start(melee_cooldown)
	attack_sound.play(0.1)
