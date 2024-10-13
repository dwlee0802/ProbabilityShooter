extends Node
class_name BulletGenerator

var items = {}

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
	var sample: Bullet = get_bullet()
	
	return copy_bullet(sample, count)

## Generates and returns copies of input bullet
func copy_bullet(sample_bullet: Bullet, count: int):
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

func apply_upgrade(effect: AddTraitEffect):
	piercing_enabled = effect.piercing or piercing_enabled
	explosive_enabled = effect.explosive or explosive_enabled
	buckshot_enabled = effect.buckshot or buckshot_enabled
	quickshot_enabled = effect.quickshot or quickshot_enabled
	fire_enabled = effect.fire or fire_enabled
	vampire_enabled = effect.vampire or vampire_enabled
	
func add_trait_chance_bonus(amount: float) -> void:
	trait_chance += amount
	trait_chance = max(trait_chance, 0)
	if amount != 0:
		print("Changed trait chance by " + str(amount))
		
func print_traits() -> String:
	var output = ""
	
	if piercing_enabled:
		output += "Piercing\n"
	if explosive_enabled:
		output += "Explosive\n"
	if buckshot_enabled:
		output += "Buckshot\n"
	if quickshot_enabled:
		output += "Quickshot\n"
	if fire_enabled:
		output += "Fire\n"
	if vampire_enabled:
		output += "Vampire\n"
		
	return output
