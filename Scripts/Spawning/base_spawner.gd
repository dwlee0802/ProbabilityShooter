extends Node
class_name EnemySpawner

var game_ref: Game
var enemy_unit_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")

func _ready() -> void:
	reset_stats()
	
func reset_stats() -> void:
	return
