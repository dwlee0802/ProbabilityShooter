extends Node
class_name BulletGenerator

## Holds stats related to bullet generation

#region Random Bullets System
## probabilities of bullets spawning with types
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
@export
var _base_vampire_chance: float = 0
var vampire_chance: float = 0
#endregion


func _ready() -> void:
	reset_stats()
	
func reset_stats() -> void:
	piercing_chance = _base_piercing_chance
	explosive_chance = _base_explosive_chance
	fire_chance = _base_fire_chance
	vampire_chance = _base_vampire_chance
	
	buckshot_chance = _base_buckshot_chance
	quickshot_chance = _base_quickshot_chance
	
func generate_bullet() -> Bullet:
	var bullet: Bullet = Bullet.new()
	if randf() < piercing_chance:
		bullet.piercing = true
	if randf() < fire_chance:
		bullet.fire = true
	if randf() < vampire_chance:
		bullet.vampire = true
	if randf() < explosive_chance:
		bullet.explosive = true
	
	print("Get bullet result: " + str(bullet))
	return bullet
	
## Generates and returns count number of bullets
func generate_bullets(count: int) -> Array:
	var sample: Bullet = generate_bullet()
	return duplicate_bullet(sample, count)
	
## Returns a list of Bullets that are duplicates of input bullet
func duplicate_bullet(sample_bullet: Bullet, count: int):
	var output = []
	var sample: Bullet = sample_bullet

	for i in range(count):
		var new_bullet: Bullet = Bullet.new()
		new_bullet.piercing = sample.piercing
		new_bullet.explosive = sample.explosive
		new_bullet.quickshot = sample.quickshot
		new_bullet.fire = sample.fire
		new_bullet.vampire = sample.vampire
		
		new_bullet.aim_time = sample.aim_time
		new_bullet.projectile_count = sample.projectile_count
			
		output.append(new_bullet)
		
	return output

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

func apply_upgrade(effect: AddTraitEffect) -> void:
	add_piercing_chance_bonus(effect.piercing_chance_bonus)
	add_explosive_chance_bonus(effect.explosive_chance_bonus)
	add_fire_chance_bonus(effect.fire_chance_bonus)
	add_quickshot_chance_bonus(effect.quickshot_chance_bonus)
	add_vampire_chance_bonus(effect.vampire_chance_bonus)
	
## Bullet Generation chance modifiers
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
		
func add_vampire_chance_bonus(amount: float) -> void:
	vampire_chance += amount
	vampire_chance = max(vampire_chance, 0)
	if amount != 0:
		print("Changed vampire chance by " + str(amount))
