extends Node
class_name EnemySpawnerComponent

## Component to take care of spawning enemies

var game_ref: Game

var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")

@export
var melee_unit: PackedScene
@export
var ranged_unit: PackedScene
@export
var sniper_unit: PackedScene
@export
var sprayer_unit: PackedScene
@export
var ghost_unit: PackedScene

var wave_timer: Timer
@export
var wave_cooldown: float = 10

@export_category("Wave Stats")
var wave_count: int = 0
@export
var max_waves: int = 20
@export
var _base_melee_spawn_count: float = 10
var melee_spawn_average: float = 10
@export
var _base_ranged_spawn_count: float = 0
var ranged_spawn_average: float = 0
@export
var _base_sniper_spawn_count: float = 0
var sniper_spawn_average: float = 0
@export
var _base_sprayer_spawn_count: float = 0
var sprayer_spawn_average: float = 0
@export
var _base_ghost_spawn_count: float = 0
var ghost_spawn_average: float = 0

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
	wave_timer.one_shot = true
	wave_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	wave_timer.timeout.connect(on_wave_timer_timeout)
	
func reset_stats() -> void:
	wave_count = 0
	
	melee_spawn_average = _base_melee_spawn_count
	ranged_spawn_average = _base_ranged_spawn_count
	sniper_spawn_average = _base_sniper_spawn_count
	sprayer_spawn_average = _base_sprayer_spawn_count
	ghost_spawn_average = _base_ghost_spawn_count
	
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
		
	var melee = []
	var ranged = []
	
	for i in range(int(randfn(melee_spawn_average, 1.2))):
		melee.append(spawn_enemy_unit())
	for i in range(int(randfn(ranged_spawn_average, 1.2))):
		ranged.append(spawn_enemy_unit(ranged_unit))
	for i in range(int(randfn(sniper_spawn_average, 1.2))):
		ranged.append(spawn_enemy_unit(sniper_unit))
	for i in range(int(randfn(sprayer_spawn_average, 1.2))):
		ranged.append(spawn_enemy_unit(sprayer_unit))
	for i in range(int(randfn(ghost_spawn_average, 1.2))):
		ranged.append(spawn_enemy_unit(ghost_unit))
	
	#print("melee: " + str(melee))
	#print("ranged: " + str(ranged))
	
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
	
func spawn_enemy_unit(scene: PackedScene = melee_unit) -> EnemyUnit:
	var unit: EnemyUnit = scene.instantiate()
	# change stats
	unit.on_spawn(
		randi_range(move_speed_range.x, move_speed_range.y),
		max(1, int(randfn(avg_health, 1.4)))
	)
	
	game_ref.add_enemy(unit)
	
	return unit

func is_max_waves_reached() -> bool:
	return max_waves <= wave_count
