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
var health_avg_bonus: int = 0

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
var wave_count_bonus: int = 0


func apply(spawner: EnemySpawnerComponent):
	spawner.avg_health += health_avg_bonus
	print("Applied Mutation: " + _to_string())

func _to_string() -> String:
	return mutation_name
