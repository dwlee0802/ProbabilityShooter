extends Node
class_name EnemyWaveComponent

## Component to take care of spawning enemies

var game_ref: Game
var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")
var wave_timer: Timer

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
var _base_move_speed_range: Vector2i = Vector2i(300, 500)
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
