extends Node
class_name BulletGenerator

## Holds stats related to bullet generation

#region Random Bullets System
## probabilities of bullets spawning with types
@export
var _base_damage_range: Vector2i = Vector2i(1,1)
var damage_range: Vector2i = Vector2i(25,125)
@export
var _base_piercing_chance: float = 0
var piercing_chance: float = 0
@export
var _base_explosive_chance: float = 0
var explosive_chance: float = 0
@export
var _base_buckshot_chance: float = 0
var buckshot_chance: float = 0
@export
var _base_quickshot_chance: float = 0
var quickshot_chance: float = 0
@export
var _base_fire_chance: float = 0
var fire_chance: float = 0
#endregion


func _ready() -> void:
	reset_stats()
	
## Generates and returns count number of bullets
func generate_bullets(count: int):
	var output = []
	var sample: Bullet = Bullet.new()
	sample.damage_amount = randi_range(damage_range.x, damage_range.y)
	sample.piercing = randf() < piercing_chance
	sample.explosive = randf() < explosive_chance
	sample.quickshot = randf() < quickshot_chance
	sample.fire = randf() < fire_chance
	sample.aim_time = 1.0
	if sample.quickshot:
		sample.aim_time = 0.5
	if randf() < buckshot_chance:
		sample.projectile_count = 4

	for i in range(count):
		var new_bullet: Bullet = Bullet.new()
		new_bullet.damage_amount = sample.damage_amount
		new_bullet.piercing = sample.piercing
		new_bullet.explosive = sample.explosive
		new_bullet.quickshot = sample.quickshot
		new_bullet.fire = sample.fire
		
		new_bullet.aim_time = sample.aim_time
		new_bullet.projectile_count = sample.projectile_count
			
		output.append(new_bullet)
		
	return output
	
func reset_stats() -> void:
	damage_range = _base_damage_range
	piercing_chance = _base_piercing_chance
	explosive_chance = _base_explosive_chance
	buckshot_chance = _base_buckshot_chance
	quickshot_chance = _base_quickshot_chance
	fire_chance = _base_fire_chance

## Bullet Generation chance modifiers
func add_bonus_damage(bonus: Vector2i) -> void:
	damage_range += bonus
	if damage_range.x < 0:
		damage_range.x = 0
	if damage_range.y < 0:
		damage_range.y = 0
	if bonus != Vector2i.ZERO:
		print("Increased damage range by " + str(bonus))
		
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
		
func add_fire_chance_bonus(amount: float) -> void:
	fire_chance += amount
	fire_chance = max(fire_chance, 0)
	if amount != 0:
		print("Changed fire chance by " + str(amount))
	
