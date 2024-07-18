extends Node2D

var enemy_scene = preload("res://Scenes/enemy_unit.tscn")

@onready var core: Core = $Core

@export_category("Wave Setting")
## time in seconds between enemy unit spawns
@export
var spawn_cooldown: float = 1.0
@onready
var spawn_timer: Timer = $SpawnTimer
## distance from core where enemy units spawn at
@export
var spawn_radius: int = 1000


# Called when the node enters the scene tree for the first time.
func _ready():
	EnemyUnit.core_position = core.global_position
	spawn_timer.timeout.connect(spawn_enemy_unit)
	spawn_timer.start(spawn_cooldown)

func spawn_enemy_unit() -> void:
	var newEnemy: EnemyUnit = enemy_scene.instantiate()
	newEnemy.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * 1000
	newEnemy.on_spawn(randi_range(100, 300), randi_range(50, 150))
	add_child(newEnemy)
