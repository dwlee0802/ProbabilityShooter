extends Resource
class_name Mutation

## Mutation objects that modify enemy spawn stats

@export
var mutation_name: String = "Null"
@export
var icon: Texture2D
@export_multiline
var description: String = "null"
@export
var color: Color = Color.WHITE

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


func on_enter(spawner: EnemySpawnerComponent, level: int):
	spawner.health_range += health_range_bonus * level
	spawner.move_speed_range += speed_range_bonus * level
	
	spawner.heavy_chance += heavy_spawn_chance_bonus * level
	
func on_exit(spawner: EnemySpawnerComponent, level: int):
	spawner.health_range -= health_range_bonus * level
	spawner.move_speed_range -= speed_range_bonus * level
	
	spawner.heavy_chance += heavy_spawn_chance_bonus * level

func _to_string() -> String:
	return mutation_name
