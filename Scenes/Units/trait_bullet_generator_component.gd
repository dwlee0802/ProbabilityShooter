extends BulletGenerator
class_name TraitBulletGenerator

@export
var _base_trait_chance: float = 0.1
var trait_chance: float = 0.1

#region Random Bullets System
## probabilities of bullets spawning with types
@export
var piercing_enabled: bool = false
@export
var explosive_enabled: bool = false
@export
var buckshot_enabled: bool = false
@export
var quickshot_enabled: bool = false
@export
var fire_enabled: bool = false
@export
var vampire_enabled: bool = false
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
		new_bullet.vampire = sample.vampire
		new_bullet.double_damage = sample.double_damage
		
		new_bullet.aim_time = sample.aim_time
		new_bullet.projectile_count = sample.projectile_count
			
		output.append(new_bullet)
		
	return output

func generate_bullets_from_sample(sample_bullet: Bullet, count: int):
	var output = []
	var sample: Bullet = sample_bullet

	for i in range(count):
		var new_bullet: Bullet = Bullet.new()
		new_bullet.damage_amount = sample.damage_amount
		new_bullet.piercing = sample.piercing
		new_bullet.explosive = sample.explosive
		new_bullet.quickshot = sample.quickshot
		new_bullet.fire = sample.fire
		new_bullet.vampire = sample.vampire
		new_bullet.double_damage = sample.double_damage
		
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
		if random_trait.double_damage:
			sample.damage_amount *= 2
		if random_trait.vampire:
			sample.vampire = true
		sample.double_damage = random_trait.double_damage
	
	print("Get bullet result: " + str(sample))
	return sample

## Returns a Bullet with the input item applied
func apply_item(bullet: Bullet, item: ItemData):
	if bullet == null or item == null:
		push_warning("Missing bullet or itemdata in apply item.")
		return null
		
	var sample: Bullet = bullet
	var random_trait: ItemData = item
	
	if random_trait.piercing_chance > 0:
		sample.piercing = true
	if random_trait.fire_chance > 0:
		sample.fire = true
	if random_trait.explosive_chance > 0:
		sample.explosive = true
	if random_trait.double_damage:
		sample.damage_amount *= 2
	if random_trait.vampire:
		sample.vampire = true
	sample.double_damage = random_trait.double_damage
	
	return bullet
	
func reset_stats() -> void:
	trait_chance = _base_trait_chance
	
	piercing_enabled = false
	explosive_enabled = false
	buckshot_enabled = false
	quickshot_enabled = false
	fire_enabled = false
	vampire_enabled = false
	
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
	
func print_traits() -> String:
	var output = ""
	for key: ItemData in items.keys():
		output += key.item_name + "\n"
		
	return output
