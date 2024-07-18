extends Node2D

var enemy_scene = preload("res://Scenes/enemy_unit.tscn")

@onready var core: Core = $Core


# Called when the node enters the scene tree for the first time.
func _ready():
	EnemyUnit.core_position = core.global_position
	var newEnemy: EnemyUnit = enemy_scene.instantiate()
	newEnemy.global_position = Vector2.RIGHT * 500
	newEnemy.on_spawn(100)
	add_child(newEnemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
