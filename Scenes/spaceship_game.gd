extends Node2D

@onready
var ship_info_label: Label = $CanvasLayer/ShipInfoLabel
@onready
var spaceship : Spaceship = $Spaceship

var enemy_scene: PackedScene = preload("res://Scenes/Units/enemy_unit.tscn")
@onready
var enemies: Node2D = $Enemies

@export
var spawn_radius: float = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	ship_info_label.text = ""
	ship_info_label.text += "LINEAR SPD: " + str(spaceship.linear_velocity.length()) + "\n"

func _on_spawn_timer_timeout() -> void:
	spawn_enemy_unit()
	
func spawn_enemy_unit() -> void:
	var newEnemy: EnemyUnit
	newEnemy = enemy_scene.instantiate()
	newEnemy.game_ref = self
	newEnemy.on_spawn(
		1000,
		100)
	enemies.add_child(newEnemy)
	newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius + spaceship.position
