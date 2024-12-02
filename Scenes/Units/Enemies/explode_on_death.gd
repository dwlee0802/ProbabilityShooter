extends Node

var parent

var fired: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	
func _process(_delta: float) -> void:
	if parent is EnemyUnit:
		if parent.is_dead():
			if !fired:
				spray_projectiles(randi_range(4, 10))
				fired = true
				
func spray_projectiles(count: int = 6):
	for i in range(count):
		shoot_projectile(Vector2.UP.rotated(TAU / count * i))
		
func shoot_projectile(dir: Vector2) -> void:
	if parent == null:
		return
		
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
			dir.normalized(),
			parent.projectile_speed, 
			parent.projectile_damage,
			0)
		new_bullet.global_position = parent.global_position
		
		new_bullet.bullet_data = Bullet.new()
			
		# add to scene
		parent.get_tree().root.get_node("Game").projectiles.add_child(new_bullet)
