extends Node2D
class_name WeaponComponent

@export
var weapon_data: GunData = null
var weapon: Gun

@onready
var state_machine: StateMachine = $StateMachine

var attack_direction_queue = []
var reload_timer: Timer

@export
var active_reload_available: bool = true
var active_reload_failed: bool = false

@onready
var attack_cone: Polygon2D = $AttackFullCone/AttackCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone
@onready
var aim_cone: Polygon2D = $AimCone
@onready
var queued_cones: Node2D = $QueuedCones

@export
var aim_color: Color = Color.DIM_GRAY
@export
var attack_color: Color = Color.RED
@export
var queued_color: Color = Color.ORANGE
@export
var background_color: Color = Color.BLACK

## sound
@onready 
var gunshot_sfx: AudioStreamPlayer2D = $GunshotSoundPlayer
@onready 
var reload_sfx: AudioStreamPlayer2D = $ReloadSoundPlayer
@onready
var active_reload_sound_player: AudioStreamPlayer = $ActiveReloadSound

#region Active Reload
var active_reload_range: Vector2i = Vector2i.ZERO
#endregion

signal bullets_changed
signal reload_started
signal reload_complete


func _ready() -> void:
	state_machine.init(self)
	weapon = Gun.new(weapon_data)
	
	reload_timer = Timer.new()
	reload_timer.autostart = false
	reload_timer.one_shot = true
	add_child(reload_timer)
	
	update_aim_cone()
	aim_cone.color = aim_color
	attack_cone.color = attack_color
	attack_full_cone.color = background_color
	

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func update_aim_cone() -> void:
	var spread: float = weapon.get_spread()
	aim_cone.polygon = cone_from_angle(spread, 100000)
	attack_full_cone.polygon = cone_from_angle(spread, 100000)
	
func update_attack_cone(progress: float) -> void:
	attack_cone.polygon = cone_from_angle(weapon.data.get_spread_in_rad() * progress, 100000)
	
func cone_from_angle(angle: float, radius: float) -> PackedVector2Array:
	# calculate three points of triangle
	var cone = []
	cone.append(Vector2.ZERO)
	cone.append(Vector2.from_angle(angle/2) * radius)
	cone.append(Vector2.from_angle(-angle/2) * radius)
	return cone

func get_queued_attack_count() -> int:
	return attack_direction_queue.size()
