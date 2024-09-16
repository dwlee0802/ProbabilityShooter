extends Node
class_name EnemySpawnerComponent

## Component to take care of spawning enemies

var game_ref: Game
var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")
var spawn_timer: Timer

@export_category("Wave Stats")
var _base_spawn_cooldown: float = 1.0
var spawn_cooldown: float = 1.0

@export_category("Enemy Stats")
@export
var _base_health_range: Vector2i = Vector2i.ZERO
var health_range: Vector2i
@export
var _base_move_speed_range: Vector2i = Vector2i.ZERO
var move_speed_range: Vector2i

@export_category("Trait Chances")
@export
var _base_heavy_chance: float = 0
var heavy_chance: float


func _ready() -> void:
	reset_stats()
	game_ref = get_parent()
	
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	spawn_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	spawn_timer.timeout.connect(on_spawn_timer_timeout)

func reset_stats() -> void:
	health_range = _base_health_range
	move_speed_range = _base_move_speed_range
	
	heavy_chance = _base_heavy_chance
	
func spawn_enemy_unit() -> EnemyUnit:
	var unit: EnemyUnit = enemy_unit_scene.instantiate()
	# change stats
	unit.on_spawn(
		randi_range(move_speed_range.x, move_speed_range.y),
		randi_range(health_range.x, health_range.y)
	)
	
	if randf() < heavy_chance:
		unit.apply_heavy()
	
	game_ref.add_enemy(unit)
	
	return unit

func on_spawn_timer_timeout() -> void:
	spawn_enemy_unit()
	spawn_timer.start(spawn_cooldown)
