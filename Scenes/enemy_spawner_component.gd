extends Node
class_name EnemySpawnerComponent

## Component to take care of spawning enemies

var game_ref: Game
var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")
var spawn_timer: Timer

@export_category("Wave Stats")
@export
var _base_spawn_cooldown: float = 2.0
var spawn_cooldown: float = 2.0
@export
var _base_wave_count: int = 3
var wave_count: int = 3
@export
var _base_wave_chance: float = 0.1
var wave_chance: float = 0.1

@export_category("Enemy Stats")
@export
var _base_health_range: Vector2i = Vector2i(1, 4)
var health_range: Vector2i
@export
var _base_move_speed_range: Vector2i = Vector2i(100, 200)
var move_speed_range: Vector2i

@export_category("Trait Chances")
@export
var _base_heavy_chance: float = 0.01
var heavy_chance: float
@export
var _base_fast_chance: float = 0.01
var fast_chance: float
@export
var _base_ranged_chance: float = 0.01
var ranged_chance: float
@export
var _base_shield_chance: float = 0.01
var shield_chance: float

signal stats_changed


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
	spawn_cooldown = _base_spawn_cooldown
	wave_chance = _base_wave_chance
	wave_count = _base_wave_count
	
	health_range = _base_health_range
	move_speed_range = _base_move_speed_range
	
	heavy_chance = _base_heavy_chance
	fast_chance = _base_fast_chance
	ranged_chance = _base_ranged_chance
	shield_chance = _base_shield_chance
	
	stats_changed.emit()
	
func spawn_enemy_unit() -> EnemyUnit:
	var unit: EnemyUnit = enemy_unit_scene.instantiate()
	# change stats
	unit.on_spawn(
		randi_range(move_speed_range.x, move_speed_range.y),
		randi_range(health_range.x, health_range.y)
	)
	
	if randf() < heavy_chance:
		unit.apply_heavy()
	if randf() < fast_chance:
		unit.apply_quick()
	if randf() < ranged_chance:
		unit.apply_ranged()
	if randf() < shield_chance:
		unit.apply_shield()
	
	game_ref.add_enemy(unit)
	
	return unit

func on_spawn_timer_timeout() -> void:
	if randf() < wave_chance:
		for i in range(wave_count):
			spawn_enemy_unit()
	else:
		spawn_enemy_unit()
		
	spawn_timer.start(spawn_cooldown)
