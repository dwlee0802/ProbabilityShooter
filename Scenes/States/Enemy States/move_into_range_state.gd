extends State

@export
var attack_state: State


func enter() -> void:
	super()
	parent.state_label.text = "State: Move to player"

func process_physics(delta: float) -> State:
	# if we are within target range, change to attack state
	if parent.player_inside_range():
		return attack_state
		
	var target_direction: Vector2 = parent.global_position.direction_to(parent.target_position)
	
	parent.movement_speed_multiplier += delta * parent.acceleration
	
	# adjust velocity to go towards core
	var current_direction: Vector2 = parent.linear_velocity.normalized()
	var current_speed: float = parent.linear_velocity.length()
	
	var adjustment_force_dir: Vector2 = target_direction - current_direction
	
	parent.apply_central_impulse(adjustment_force_dir * parent.adjust_modifier)
	
	# bring speed back to normal
	if current_speed > parent.get_movement_speed():
		parent.apply_central_impulse(abs(current_speed - parent.get_movement_speed()) * -current_direction * parent.speed_adjust_modifier * delta)
	else:
		parent.apply_central_impulse(abs(current_speed - parent.get_movement_speed()) * parent.speed_adjust_modifier * current_direction * delta)
	
	return null
