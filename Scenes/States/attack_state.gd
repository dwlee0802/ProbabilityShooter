extends State

var mouse_position: Vector2

@export
var projectile_speed: float = 1000

@export
var idle_state: State
@export
var move_state: State

@onready
var timer: Timer = $Timer


func enter() -> void:
	super()
	parent.state_label.text = "Action1"
	timer.start(2)

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed('right_click'):
		return move_state
		 
	return null

func process_frame(_delta: float) -> State:
	parent.state_label.text = "Action1 in " + str(int(timer.time_left + 1))
	return null
	
func process_physics(_delta: float) -> State:
	if timer.is_stopped():
		parent.action_1_available = false
		
		var bullet: Projectile = parent.bullet_scene.instantiate()
		bullet.Launch(mouse_position.normalized(), projectile_speed)
		bullet.global_position = parent.global_position
		
		get_tree().root.add_child(bullet)
		
		return idle_state
	
	return null
