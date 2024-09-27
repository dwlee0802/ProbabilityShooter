extends Node2D
class_name PlayerArmComponent

@onready
var arm_one: Node2D = $ArmOne
@onready
var arm_two: Node2D = $ArmTwo

var current_arm: Node2D

func _ready() -> void:
	current_arm = arm_one

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("action_one") or event.is_action_pressed("action_two"):
			point_arm_at(get_local_mouse_position())
			
func point_arm_at(target_pos: Vector2) -> void:
	var angle: float = Vector2.RIGHT.angle_to_point(target_pos)
	current_arm.rotation = angle
	
	# alternate arms
	if current_arm == arm_one:
		current_arm = arm_two
	else:
		current_arm = arm_one
