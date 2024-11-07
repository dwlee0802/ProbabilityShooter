extends State

@export
var move_state: State

var attack_timer: Timer

func _ready() -> void:
	var new_timer: Timer = Timer.new()
	new_timer.autostart = false
	new_timer.one_shot = false
	attack_timer = new_timer
	attack_timer.timeout.connect(shoot_projectile)
	add_child(new_timer)

func enter() -> void:
	super()
	parent.state_label.text = "State: Attack"
	
	attack_timer.start(parent.attack_cooldown)
	
	parent.attack_line.set_point_position(1, parent.target_position - parent.global_position)
	parent.attack_line.visible = true

func exit() -> void:
	super()
	attack_timer.stop()
	
	parent.attack_line.visible = false
	
func process_frame(_delta: float) -> State:
	if parent.is_dead():
		if !attack_timer.is_stopped():
			attack_timer.stop()
	
	if attack_timer.time_left < 0.6:
		parent.attack_line.get_node("AnimationPlayer").play("attack_blink")
		
	return null
	
func process_input(_event: InputEvent) -> State:
	return null
	
func process_physics(_delta: float) -> State:
	# change to move state if out of range from target
	if !parent.player_inside_range():
		return move_state
	
	parent.attack_line.set_point_position(1, parent.target_position - parent.global_position)
	
	return null

func shoot_projectile() -> void:
	if parent.projectile != null:
		var new_bullet: Projectile = parent.projectile.instantiate()
		new_bullet.is_player = false
		
		new_bullet.apply_scale(Vector2(2,2))
		new_bullet.get_node("Sprite2D").self_modulate = Color.RED
		new_bullet.get_node("Line2D").visible = false
		new_bullet.lifetime_limit = 10
		
		# set stats
		# save origin unit to call back for experience gain
		new_bullet.origin_unit = self
		new_bullet.launch(
			parent.global_position.direction_to(parent.target_position).normalized(),
			parent.projectile_speed, 
			parent.projectile_damage,
			0)
		new_bullet.global_position = parent.global_position
		
		new_bullet.bullet_data = Bullet.new()
			
		# add to scene
		parent.get_tree().root.get_node("Game").projectiles.add_child(new_bullet)
