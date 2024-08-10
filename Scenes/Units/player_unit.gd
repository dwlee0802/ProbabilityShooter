extends Unit
class_name PlayerUnit

@onready
var state_label: Label = $StateLabel
@onready
var state_machine: StateMachine = $StateMachine

@onready
var shortcut_label: Label = $ShortcutLabel

@export_category("Unit Stats")
@export
var movement_speed: float = 100
var movement_speed_bonus: float = 0
var movement_speed_multiplier: float = 1.0
@export
var temp_color: Color = Color.WHITE
@export
var damage_range: Vector2i = Vector2i(10, 150)
var damage_bonus: Vector2i = Vector2i(0, 0)
@export
var health_points: float = 500
@export
var max_health_points: int = 500
@onready
var health_bar: DelayedProgressBar = $HealthBar
@onready
var revive_time: float = 5.0

@export_category("Equipment")
@export
var current_equipped_index: int = 0
@export
var equipments = []
@export
var starting_equipment: Resource
@export
var starting_equipments = []
## dictionary<ItemData data, int level> to store items this unit got
var items = {}
@export
var starting_item: ItemData = null

@onready
var action_one_reload_timer: Timer = $ActionOneReloadTimer

@export_category("Aim Line")
@export
var aim_color: Color = Color.DIM_GRAY
@export
var attack_color: Color = Color.RED
@export
var queued_color: Color = Color.ORANGE
@export
var background_color: Color = Color.BLACK

@onready
var arm: Node2D = $Arm
@onready
var aim_line: Line2D = $AimLine
@onready
var attack_line: Line2D = $AttackLine
@onready
var attack_cone: Polygon2D = $AttackFullCone/AttackCone
@onready
var attack_full_cone: Polygon2D = $AttackFullCone
@onready
var aim_cone: Polygon2D = $AimCone
@onready
var attack_line_anim: AnimationPlayer = $AttackLine/AnimationPlayer
@onready
var move_line: Line2D = $MoveLine

## interaction
@onready
var interaction_area: Area2D = $InteractionArea

## sound
@onready var gunshot_sfx: AudioStreamPlayer2D = $GunshotSoundPlayer
@onready var reload_sfx: AudioStreamPlayer2D = $ReloadSoundPlayer

signal was_selected
signal deselected
signal health_changed
signal was_attacked
signal knocked_out
signal revived
signal equipment_changed
signal picked_up_item(item)


func _ready() -> void:
	# instantiate gun objects
	for eq: EquipmentData in starting_equipments:
		if eq is RayGunData:
			equipments.append(RayGun.new(eq))
		elif eq is GrenadeData:
			equipments.append(Grenade.new(eq))
		elif eq is ShotgunData:
			equipments.append(Shotgun.new(eq))
		else:
			equipments.append(Gun.new(eq))
	
	$ActionOneReloadTimer.timeout.connect(reload_action)
	equipment_changed.connect($ActionOneReloadTimer.stop)
	equipment_changed.connect(update_aim_cone)
	update_aim_cone()
	print("equipped " + get_current_equipment().data.equipment_name)
	
	aim_line.default_color = aim_color
	attack_line.default_color = attack_color
	# cone colors
	aim_cone.color = aim_color
	attack_cone.color = attack_color
	attack_full_cone.color = background_color
	
	state_machine.init(self)
	$Sprite2D.self_modulate = temp_color
	
	# unit health
	health_points = int(max_health_points)
	health_bar.set_max(max_health_points)
	health_bar.change_value(health_points)
	
	if get_current_equipment() is Gun:
		get_current_equipment().spread_changed.connect(update_aim_cone)
		
	# make starting item
	add_item(starting_item)

func set_shortcut_label(num: int) -> void:
	$ShortcutLabel.text = str(num)
	
func _unhandled_input(event: InputEvent) -> void:
	if !InputManager.IsSelected(self):
		return
		
	state_machine.process_input(event)
	
	if Input.is_action_just_pressed("action_one"):
		# do we need to reload?
		if get_current_equipment() != null and !get_current_equipment().ready:
			# start reload
			if action_one_reload_timer.is_stopped():
				action_one_reload_timer.start(get_current_equipment().get_reload_time())
			
	if Input.is_action_just_pressed("switch_equipment"):
		current_equipped_index += 1
		current_equipped_index = current_equipped_index % equipments.size()
		equipment_changed.emit()
		print("current equipment: " + get_current_equipment().data.equipment_name)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	# make aim line follow mouse cursor
	aim_line.visible = InputManager.IsSelected(self)
	aim_cone.visible = aim_line.visible
	if InputManager.IsSelected(self):
		aim_line.set_point_position(1, get_local_mouse_position().normalized() * 10000)
		aim_cone.rotation = Vector2.ZERO.angle_to_point(get_local_mouse_position())

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func reload_action() -> void:
	if current_equipped_index < equipments.size():
		equipments[current_equipped_index].ready = true
		if equipments[current_equipped_index] is Gun:
			equipments[current_equipped_index].reload()
		reload_sfx.stream = equipments[current_equipped_index].data.reload_sound
		reload_sfx.play()
	else:
		push_error("Reload equipment index out of bounds!")
	
func receive_hit(amount: float) -> void:
	health_points -= amount
	health_points = max(health_points, 0)
	if health_points <= 0:
		knocked_out.emit()
		disable_enemy_collision()
		
	health_bar.change_value(health_points)
	health_changed.emit()
	was_attacked.emit()

func add_health(amount: float) -> void:
	if health_points <= 0 and amount > 0:
		revived.emit()
		$CollisionShape2D.disabled = false
		enable_enemy_collision()
		
	health_points += amount
	health_points = min(max_health_points, health_points)
	health_bar.change_value(health_points)
	health_changed.emit()

func reset_health() -> void:
	health_points = max_health_points
	health_bar.change_value(max_health_points, true)
	health_changed.emit()

func is_unconscious() -> bool:
	return health_points <= 0
	
func _on_body_entered(body):
	if body is EnemyUnit:
		receive_hit(body.health_points)
		body.die()

func disable_enemy_collision():
	$CollisionShape2D.call_deferred("set_disabled", true)
	print("disabled collision")
func enable_enemy_collision():
	$CollisionShape2D.call_deferred("set_disabled", false)
	print("enabled collision")

func get_current_equipment():
	if current_equipped_index < equipments.size():
		return equipments[current_equipped_index]
func get_other_equipment():
	if current_equipped_index + 1 < equipments.size():
		return equipments[current_equipped_index + 1]
	else:
		return equipments[current_equipped_index - 1]

func get_movement_speed() -> float:
	return (movement_speed + movement_speed_bonus) * movement_speed_multiplier

func set_movement_line(points) -> void:
	move_line.clear_points()
	move_line.add_point(Vector2.ZERO)
	for pt: Vector2 in points:
		move_line.add_point(pt)

func cone_from_angle(angle: float, radius: float) -> PackedVector2Array:
	# calculate three points of triangle
	var cone = []
	cone.append(Vector2.ZERO)
	cone.append(Vector2.from_angle(angle/2) * radius)
	cone.append(Vector2.from_angle(-angle/2) * radius)
	return cone

func update_attack_cone(progress: float) -> void:
	attack_cone.polygon = cone_from_angle(get_current_equipment().get_spread() * progress, 100000)

func update_aim_cone() -> void:
	var spread: float = get_current_equipment().get_spread()
	aim_cone.polygon = cone_from_angle(spread, 100000)
	attack_full_cone.polygon = cone_from_angle(spread, 100000)
	
## progression system methods
func add_item(item: ItemData) -> void:
	# if it exists, increase level
	if items.find_key(item):
		item.on_exit(self, items[item])
		items[item] += 1
		item.on_enter(self, items[item])
	else:
		items[item] = 1
		item.on_enter(self, items[item])
	
	picked_up_item.emit(item)
		
func reset_items() -> void:
	for item in items.keys():
		item.on_exit(self, items[item])
	items.clear()
