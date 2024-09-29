extends Equipment
class_name Gun

static var bullet_generator: BulletGenerator

var reload_speed_modifier: float = 0
var aim_speed_modifier: float = 0

static var max_reload_time: float = 60
static var max_aim_time: float = 60

@export
var current_magazine_count: int = 6

#region Random Bullets System
## array that holds the randomly generated Bullet objects
var bullets = []
## Max number of bullets gun can have
var max_bullet_count: int = 6

## probabilities of bullets spawning with types
var damage_range: Vector2i = Vector2i(25,125)
var anti_armor_chance: float = 0
var piercing_chance: float = 0
var explosive_chance: float = 0
var buckshot_chance: float = 0
var quickshot_chance: float = 0
#endregion

@export
var bonus_damage_range: Vector2i = Vector2i.ZERO
@export
var damage_multiplier: float = 0
## how much faster projectiles fly
@export
var bonus_projectile_speed: int = 0
@export
var bonus_spread: float = 0
static var min_spread: float = 0.1 /360 * PI
@export
var bonus_projectile_count: int = 0
@export
var bonus_magazine_size: int = 0
@export
var bonus_penetration: float = 0

## Debugging
var print_bullet_info: bool = false

signal spread_changed


func _init(_data: EquipmentData):
	super(_data)
	
func on_activation(unit: Unit, mouse_position: Vector2):
	var current_bullet: Bullet = bullets.pop_front()
	
	for i in range(current_bullet.projectile_count):
		# make new projectile
		var new_bullet: Projectile = data.projectile_scene.instantiate()
			
		var random_spread_offset: float = randf_range(-get_spread()/2, get_spread()/2)
		# set stats
		# save origin unit to call back for experience gain
		new_bullet.origin_unit = unit
		new_bullet.launch(
			mouse_position.normalized().rotated(random_spread_offset * (current_bullet.projectile_count)), 
			get_projectile_speed(), 
			int(current_bullet.damage_amount / float(current_bullet.projectile_count)), 
			data.knock_back_force)
		new_bullet.global_position = unit.global_position
		
		new_bullet.bullet_data = current_bullet
			
		# add to scene
		unit.get_tree().root.get_node("Game").projectiles.add_child(new_bullet)
	
	current_magazine_count -= 1
	
	CameraControl.camera.shake_screen(20,200)
	
	super.on_activation(unit, mouse_position)
	
	return current_bullet.damage_amount

func reset_stats() -> void:
	damage_range = Vector2i(25,125)
	anti_armor_chance = 0
	piercing_chance = 0
	explosive_chance = 0
	buckshot_chance = 0
	quickshot_chance = 0
	
func have_bullets() -> bool:
	return current_magazine_count > 0
	
func reload() -> void:
	current_magazine_count = get_magazine_size()
	print("reloaded " + data.equipment_name + " " + str(current_magazine_count) + "/" + str(get_magazine_size()))
	bullets = Gun.bullet_generator.generate_bullets(get_magazine_size())
	
func clear_bullets() -> void:
	print("removed " + str(current_magazine_count) + " bullets")
	current_magazine_count = 0
	bullets.clear()

#region Random Bullets System
func generate_bullets(count: int):
	var output = []
	for i in range(count):
		var new_bullet: Bullet = Bullet.new()
		new_bullet.damage_amount = randi_range(get_damage_range().x, get_damage_range().y)
		new_bullet.piercing = randf() < piercing_chance
		print(randf())
		new_bullet.anti_armor = randf() < anti_armor_chance
		new_bullet.explosive = randf() < explosive_chance
		new_bullet.quickshot = randf() < quickshot_chance
		
		new_bullet.aim_time = 1
		if new_bullet.quickshot:
			new_bullet.aim_time = 0.5
		
		if randf() < buckshot_chance:
			new_bullet.projectile_count = 4
			
		output.append(new_bullet)
	print(output)
	return output
#endregion
	
func add_bonus_damage(bonus: Vector2i) -> void:
	bonus_damage_range += bonus
	if bonus_damage_range.x < 0:
		bonus_damage_range.x = 0
	if bonus_damage_range.y < 0:
		bonus_damage_range.y = 0
	if bonus != Vector2i.ZERO:
		print(data.equipment_name + " has bonus damage of " + str(bonus_damage_range))

func add_damage_multiplier(amount: float) -> void:
	damage_multiplier += amount
	if amount != 0:
		print(data.equipment_name + " has damage modifier of " + str(damage_multiplier))
		
func add_bonus_projectile_speed(amount: int) -> void:
	bonus_projectile_speed += amount
	if amount != 0:
		print(data.equipment_name + " has bonus speed of " + str(bonus_projectile_speed))

func add_bonus_spread(amount: float) -> void:
	bonus_spread += amount / 180.0 * PI
	if abs(amount) > 0.01:
		print(data.equipment_name + " has bonus spread of " + str(bonus_spread))
		spread_changed.emit()

func add_bonus_projectile_count(amount: int) -> void:
	bonus_projectile_count += amount
	if amount != 0:
		print(data.equipment_name + " has bonus projectile count of " + str(bonus_projectile_count))

func add_bonus_magazine_size(amount: int) -> void:
	bonus_magazine_size += amount
	if amount != 0:
		print(data.equipment_name + " has bonus magazine size of " + str(bonus_magazine_size))
	
func add_reload_speed_modifier(amount: float) -> void:
	reload_speed_modifier += amount
	if amount != 0:
		print("Changed reload speed modifier by " + str(amount))
		
func add_aim_speed_modifier(amount: float) -> void:
	aim_speed_modifier += amount
	if amount != 0:
		print("Changed aiming speed modifier by " + str(amount))

func add_penetration_bonus(amount: float) -> void:
	bonus_penetration += amount
	if amount != 0:
		print("Changed penetration amount modifier by " + str(amount))
		
		
## Bullet Generation chance modifiers
func add_anti_armor_chance_bonus(amount: float) -> void:
	anti_armor_chance += amount
	anti_armor_chance = max(anti_armor_chance, 0)
	if amount != 0:
		print("Changed anti armor chance by " + str(amount))
		
func add_piercing_chance_bonus(amount: float) -> void:
	piercing_chance += amount
	piercing_chance = max(piercing_chance, 0)
	if amount != 0:
		print("Changed piercing chance by " + str(amount))
		
func add_explosive_chance_bonus(amount: float) -> void:
	explosive_chance += amount
	explosive_chance = max(explosive_chance, 0)
	if amount != 0:
		print("Changed explosive chance by " + str(amount))
		
func add_buckshot_chance_bonus(amount: float) -> void:
	buckshot_chance += amount
	buckshot_chance = max(buckshot_chance, 0)
	if amount != 0:
		print("Changed buckshot chance by " + str(amount))
		
func add_quickshot_chance_bonus(amount: float) -> void:
	quickshot_chance += amount
	quickshot_chance = max(quickshot_chance, 0)
	if amount != 0:
		print("Changed quickshot chance by " + str(amount))
	
func get_damage_range() -> Vector2i:
	return damage_range + bonus_damage_range
func get_projectile_speed() -> float:
	return data.projectile_speed + bonus_projectile_speed
func get_spread() -> float:
	return max(data.get_spread_in_rad() + bonus_spread, Gun.min_spread)
func get_magazine_size() -> int:
	return max_bullet_count
func get_projectile_count() -> int:
	return data.projectile_count + bonus_projectile_count
func get_reload_time() -> float:
	if 1 + reload_speed_modifier <= 0:
		return Gun.max_reload_time
	return data.reload_time / (1 + reload_speed_modifier)
func get_aim_time() -> float:
	if 1 + aim_speed_modifier <= 0:
		return bullets.front().aim_time
	return bullets.front().aim_time * (1 - aim_speed_modifier)
func get_penetration() -> float:
	if data.penetration + bonus_penetration < 0:
		return 0
	return data.penetration + bonus_penetration
