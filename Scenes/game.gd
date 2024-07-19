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

## node to hold enemy units
@onready
var enemies: Node2D = $Enemies

@export_category("Debugging")
@export
var no_game_over: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	EnemyUnit.core_position = core.global_position
	core.core_killed.connect(game_over)
	spawn_timer.timeout.connect(spawn_enemy_unit)
	spawn_timer.start(spawn_cooldown)

func spawn_enemy_unit() -> void:
	var newEnemy: EnemyUnit = enemy_scene.instantiate()
	newEnemy.on_spawn(randi_range(100, 300), randi_range(50, 150))
	enemies.add_child(newEnemy)
	newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius

func game_over() -> void:
	if no_game_over:
		return
		
	print("***GAME OVER***")
	spawn_timer.stop()
	
	# remove all remaining enemy units
	remove_child(enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
