extends Node
class_name BulletGenerator

## Holds stats related to bullet generation

## dictionary<ItemData data, int level> to store items this unit got
var items = {}
@export
var _base_trait_chance: float = 0.1
var trait_chance: float = 0.1

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
	var sample: Bullet = get_bullet()

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

func get_bullet() -> Bullet:
	var sample: Bullet = Bullet.new()
	var traits = items.keys().duplicate()
	
	while trait_chance > randf() and traits.size() > 0:
		# add random trait
		if items.keys().is_empty():
			break
		traits.shuffle()
		var random_trait = traits.pop_front()
		if random_trait.piercing_chance > 0:
			sample.piercing = true
		if random_trait.fire_chance > 0:
			sample.fire = true
		if random_trait.explosive_chance > 0:
			sample.explosive = true
	
	print("Get bullet result: " + str(sample))
	return sample
	
func reset_stats() -> void:
	trait_chance = _base_trait_chance
	
	damage_range = _base_damage_range
	piercing_chance = _base_piercing_chance
	explosive_chance = _base_explosive_chance
	buckshot_chance = _base_buckshot_chance
	quickshot_chance = _base_quickshot_chance
	fire_chance = _base_fire_chance
	
	items.clear()

## Bullet Generation chance modifiers
func add_bonus_damage(bonus: Vector2i) -> void:
	damage_range += bonus
	if damage_range.x < 0:
		damage_range.x = 0
	if damage_range.y < 0:
		damage_range.y = 0
	if bonus != Vector2i.ZERO:
		print("Increased damage range by " + str(bonus))
		
func add_trait_chance_bonus(amount: float) -> void:
	trait_chance += amount
	trait_chance = max(trait_chance, 0)
	if amount != 0:
		print("Changed trait chance by " + str(amount))
		
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
	
