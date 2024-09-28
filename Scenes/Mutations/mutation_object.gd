extends Resource
class_name Mutation

## Mutation objects that modify enemy spawn stats

@export
var mutation_name: String = "Null"
@export
var icon: Texture2D
var default_icon = preload("res://Art/32x32_white_square.png")
@export_multiline
var description: String = "null"
@export
var color: Color = Color.WHITE
## Only appear as an option if this mutation is already present
@export
var prereq: Mutation = null
@export
var disabled: bool = false

@export_category("Stat Changes")
@export
var health_range_bonus: Vector2i = Vector2i.ZERO
@export
var speed_range_bonus: Vector2i = Vector2i.ZERO

@export_category("Trait Probability Changes")
@export
var heavy_spawn_chance_bonus: float = 0
@export
var fast_spawn_chance_bonus: float = 0
@export
var ranged_spawn_chance_bonus: float = 0
@export
var shield_spawn_chance_bonus: float = 0

@export_category("Wave Stat Chances")
@export
var spawn_cooltime_multiplier: float = 0
@export
var wave_chance_bonus: float = 0


func on_enter(spawner: EnemySpawnerComponent, level: int):
	spawner.health_range += health_range_bonus * level
	spawner.move_speed_range += speed_range_bonus * level
	
	spawner.heavy_chance += heavy_spawn_chance_bonus * level
	spawner.fast_chance += fast_spawn_chance_bonus * level
	spawner.ranged_chance += ranged_spawn_chance_bonus * level
	spawner.shield_chance += shield_spawn_chance_bonus * level
	
	spawner.wave_chance += wave_chance_bonus
	
func on_exit(spawner: EnemySpawnerComponent, level: int):
	spawner.health_range -= health_range_bonus * level
	spawner.move_speed_range -= speed_range_bonus * level
	
	spawner.heavy_chance -= heavy_spawn_chance_bonus * level
	spawner.fast_chance -= fast_spawn_chance_bonus * level
	spawner.ranged_chance -= ranged_spawn_chance_bonus * level
	spawner.shield_chance -= shield_spawn_chance_bonus * level
	
	spawner.wave_chance -= wave_chance_bonus

func _to_string() -> String:
	return mutation_name
