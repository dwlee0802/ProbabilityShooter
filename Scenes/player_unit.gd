extends Unit
class_name PlayerUnit

static var bullet_scene = preload("res://Scenes/projectile.tscn")

@onready
var state_label: Label = $StateLabel
@onready
var state_machine: StateMachine = $StateMachine

@export_category("Unit Stats")
@export
var movement_speed: float = 100

@export_category("Action Availability")
@export
var action_one_available: bool = true
@export
var action_one_reload_time: float = 1
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


func _ready() -> void:
	state_machine.init(self)
	$ActionOneReloadTimer.reload_finished.connect(reload_action)
	aim_line.default_color = default_color
	attack_line.default_color = attack_color
	
func _unhandled_input(event: InputEvent) -> void:
	if !InputManager.IsSelected(self):
		return
		
	state_machine.process_input(event)
	
	if Input.is_action_just_pressed("action_one") and !action_one_available:
		if action_one_reload_timer.is_stopped():
			action_one_reload_timer.start(action_one_reload_time)
	
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
	# make aim line follow mouse cursor
	aim_line.visible = InputManager.IsSelected(self)
	if InputManager.IsSelected(self):
		aim_line.set_point_position(1, get_local_mouse_position().normalized() * 10000)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	
func reload_action(num: int) -> void:
	match num:
		1:
			action_one_available = true

