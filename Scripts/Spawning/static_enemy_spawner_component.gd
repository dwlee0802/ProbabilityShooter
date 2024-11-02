extends Node
class_name EnemySpawnerComponent

## Component to take care of spawning enemies

var game_ref: Game
var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")
var wave_timer: Timer
@export
var wave_cooldown: float = 30

@export_category("Wave Stats")
var wave_count: int = 0
@export
var _base_melee_spawn_count: int = 5
var melee_spawn_count: int = 5
@export
var _base_ranged_spawn_count: int = 0
var ranged_spawn_count: int = 0

@export_category("Mutation Setting")
@export
var waves_per_mutation: int = 3
var next_mutation: Mutation = null

@export_category("Enemy Stats")
@export
var _base_health_range: Vector2i = Vector2i(1, 2)
var health_range: Vector2i
@export
var _base_move_speed_range: Vector2i = Vector2i(200, 400)
var move_speed_range: Vector2i

@export_category("Trait Chances")
@export
var _base_heavy_chance: float = 0
var heavy_chance: float
@export
var _base_fast_chance: float = 0
var fast_chance: float
@export
var _base_ranged_chance: float = 0
var ranged_chance: float
@export
var _base_shield_chance: float = 0
var shield_chance: float

signal stats_changed
signal wave_started

func _ready() -> void:
	reset_stats()
	game_ref = get_parent()
	
	wave_timer = Timer.new()
	add_child(wave_timer)
	wave_timer.autostart = false
	wave_timer.one_shot = false
	wave_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wave_timer.timeout.connect(on_wave_timer_timeout)
	
func reset_stats() -> void:
	wave_count = 0
	
	melee_spawn_count = _base_melee_spawn_count
	ranged_spawn_count = _base_ranged_spawn_count
	
	health_range = _base_health_range
	move_speed_range = _base_move_speed_range
	
	heavy_chance = _base_heavy_chance
	fast_chance = _base_fast_chance
	ranged_chance = _base_ranged_chance
	shield_chance = _base_shield_chance
	
	stats_changed.emit()
	
func on_wave_timer_timeout() -> void:
	for i in range(melee_spawn_count):
		spawn_enemy_unit()
	if wave_timer.is_stopped():
		wave_timer.start(wave_cooldown)
	wave_count += 1
	wave_started.emit()
	print("Spawning wave #" + str(wave_count))
	
	if wave_count % waves_per_mutation == 0:
		# apply mutation
		apply_mutation(next_mutation)
		next_mutation = Game.mutation_data.pick_random()
		print("Next Mutation is: " + str(next_mutation))

func apply_mutation(mutation: Mutation) -> void:
	if mutation == null:
		return
	print("Applied Mutation: " + str(mutation))
	
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
