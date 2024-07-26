extends Unit
class_name PlayerUnit

static var bullet_scene = preload("res://Scenes/deathray.tscn")

@onready
var state_label: Label = $StateLabel
@onready
var state_machine: StateMachine = $StateMachine

@onready
var shortcut_label: Label = $ShortcutLabel

@export_category("Unit Stats")
@export
var movement_speed: float = 100
@export
var temp_color: Color = Color.WHITE
@export
var damage_range: Vector2 = Vector2(10, 150)
@export
var health_points: int = 500
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

@onready
var action_one_reload_timer: Timer = $ActionOneReloadTimer

@export_category("Aim Line")
@export
var default_color: Color = Color.DIM_GRAY
@export
var attack_color: Color = Color.RED
@export
var disabled_color: Color = Color.DIM_GRAY

@onready
var aim_line: Line2D = $AimLine
@onready
var attack_line: Line2D = $AttackLine
@onready
var attack_line_anim: AnimationPlayer = $AttackLine/AnimationPlayer

# interaction
@onready
var interaction_area: Area2D = $InteractionArea

signal was_selected
signal deselected
signal health_changed
signal was_attacked
signal knocked_out
signal revived
signal equipment_changed


func _ready() -> void:
	$ActionOneReloadTimer.timeout.connect(reload_action)
	equipment_changed.connect($ActionOneReloadTimer.stop)
	print("equipped " + get_current_equipment().equipment_name)
	
	aim_line.default_color = default_color
	attack_line.default_color = attack_color
	state_machine.init(self)
	$Sprite2D.self_modulate = temp_color
	
	# unit health
	health_points = max_health_points
	health_bar.set_max(max_health_points)
	health_bar.change_value(health_points)

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
				action_one_reload_timer.start(get_current_equipment().reload_time)
			
	if Input.is_action_just_pressed("switch_equipment"):
		current_equipped_index += 1
		current_equipped_index = current_equipped_index % equipments.size()
		equipment_changed.emit()
		print("current equipment: " + get_current_equipment().equipment_name)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	# make aim line follow mouse cursor
	aim_line.visible = InputManager.IsSelected(self)
	if InputManager.IsSelected(self):
		aim_line.set_point_position(1, get_local_mouse_position().normalized() * 10000)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func reload_action() -> void:
	if current_equipped_index < equipments.size():
		equipments[current_equipped_index].ready = true
		if equipments[current_equipped_index] is Gun:
			equipments[current_equipped_index].reload()
	else:
		push_error("Reload equipment index out of bounds!")

func receive_hit(amount: int) -> void:
	health_points -= amount
	health_points = max(health_points, 0)
	if health_points <= 0:
		knocked_out.emit()
		disable_enemy_collision()
		
	health_bar.change_value(health_points)
	health_changed.emit()
	was_attacked.emit()
	
func add_health(amount: int) -> void:
	if health_points <= 0 and amount > 0:
		revived.emit()
		$CollisionShape2D.disabled = false
		enable_enemy_collision()
		
	health_points += amount
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
