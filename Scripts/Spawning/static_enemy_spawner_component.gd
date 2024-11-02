extends Node
class_name EnemySpawnerComponent

## Component to take care of spawning enemies

var game_ref: Game
var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")
var wave_timer: Timer
@export
var wave_cooldown: float = 20

@export_category("Wave Stats")
var wave_count: int = 0
@export
var max_waves: int = 20
@export
var _base_melee_spawn_count: float = 5
var melee_spawn_average: float = 5
@export
var _base_ranged_spawn_count: float = 0
var ranged_spawn_average: float = 0

@export_category("Mutation Setting")
@export
var waves_per_mutation: int = 3
var next_mutation: Mutation = null

@export_category("Enemy Stats")
@export
var _base_avg_health: float = 1
var avg_health: float
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
signal max_wave_reached

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
	
	melee_spawn_average = _base_melee_spawn_count
	ranged_spawn_average = _base_ranged_spawn_count
	
	avg_health = _base_avg_health
	move_speed_range = _base_move_speed_range
	
	heavy_chance = _base_heavy_chance
	fast_chance = _base_fast_chance
	ranged_chance = _base_ranged_chance
	shield_chance = _base_shield_chance
	
	stats_changed.emit()
	
func on_wave_timer_timeout() -> void:
	if wave_count < max_waves:
		wave_count += 1
		wave_started.emit()
		print("Spawning wave #" + str(wave_count))
	else:
		print("Max Wave Reached!")
		wave_timer.stop()
		max_wave_reached.emit()
		return
		
	if wave_timer.is_stopped():
		wave_timer.start(wave_cooldown)
	
	var melee = []
	var ranged = []
	
	for i in range(int(randfn(melee_spawn_average, 1.2))):
		melee.append(spawn_enemy_unit())
	for i in range(int(randfn(ranged_spawn_average, 1.2))):
		ranged.append(spawn_enemy_unit())
		ranged.back().apply_ranged()
	
	print("melee: " + str(melee))
	print("ranged: " + str(ranged))
	
	if wave_count % waves_per_mutation == 0:
		# apply mutation
		apply_mutation(next_mutation)
		next_mutation = Game.mutation_data.pick_random()
		print("Next Mutation is: " + str(next_mutation))
		
	print("********\n")

func apply_mutation(mutation: Mutation) -> void:
	if mutation == null:
		return
	mutation.apply(self)
	
func spawn_enemy_unit() -> EnemyUnit:
	var unit: EnemyUnit = enemy_unit_scene.instantiate()
	# change stats
	unit.on_spawn(
		randi_range(move_speed_range.x, move_speed_range.y),
		max(1, int(randfn(avg_health, 1.4)))
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

func is_max_waves_reached() -> bool:
	return max_waves <= wave_count
