extends State

@export
var idle_state: State

var destination: Vector2


func enter() -> void:
	super()
	parent.state_label.text = "Move"
	destination = parent.get_global_mouse_position()
	print(destination)

func process_input(_event: InputEvent) -> State:
	# right clicking when Idle is move order
	if Input.is_action_just_pressed("ui_cancel"):
		return idle_state
	if Input.is_action_just_pressed("right_click"):
		destination = parent.get_global_mouse_position()
		print(destination)
		
	return null

func process_physics(_delta: float) -> State:
	if destination.distance_to(parent.global_position) < 1:
		print("arrived")
		return idle_state
	
	var direction: Vector2 = parent.global_position.direction_to(destination)
	parent.move_and_collide(direction * parent.movement_speed * _delta)
	
	return null
