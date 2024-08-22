extends Node2D
class_name Turret

@onready
var aim_timer: Timer = $AimTimer
@export
var aim_time: float = 1.0
@onready
var aim_cone: Polygon2D = $AimCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone
@onready
var queued_cones: Node2D = $QueuedCones
var queued_attack_cones = []

var projectile_scene: PackedScene = preload("res://Scenes/Units/projectile.tscn")


func _ready() -> void:
	aim_timer.timeout.connect(on_aim_timer_timeout)
	update_aim_cone()

func _physics_process(delta: float) -> void:
	aim_cone.rotation = Vector2.ZERO.angle_to_point(get_local_mouse_position())
		
func start_attack_process():
	aim_timer.start(aim_time)
	make_queued_attack_cone(get_local_mouse_position())
	
func on_aim_timer_timeout() -> void:
	var new_projectile: Projectile = projectile_scene.instantiate()
	new_projectile.global_position = global_position
	get_tree().root.add_child(new_projectile)
	new_projectile.launch(Vector2.from_angle(queued_attack_cones.front().global_rotation), 5000, 100, 100)
	var used_attack_cone = queued_attack_cones.pop_front()
	queued_cones.remove_child(used_attack_cone)
	used_attack_cone.queue_free()

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

func make_queued_attack_cone(dir: Vector2) -> void:
	var new_attack_cone: Polygon2D = Polygon2D.new()
	new_attack_cone.polygon = attack_full_cone.polygon
	new_attack_cone.color = Color.YELLOW
	new_attack_cone.rotate(dir.angle())
	queued_cones.add_child(new_attack_cone)
	queued_attack_cones.append(new_attack_cone)
