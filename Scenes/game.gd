extends Node2D

@onready
var user_interface: UserInterface = $UserInterface

var enemy_scene = preload("res://Scenes/Units/enemy_unit.tscn")

@onready var core: Core = $Core
@export var core_health: int = 1000

var units = []

@export_category("Wave Setting")
var time_since_start: float = 0
## number of units per wave
@export
var wave_unit_count: int = 10
## time in seconds between enemy unit spawns
@export
var time_between_waves: float = 30
@export
var enemy_health_range: Vector2i = Vector2i(50, 150)
@export
var enemy_speed_range: Vector2i = Vector2i(25, 100)
## timer for resting periods between waves
@onready
var wave_timer: Timer = $WaveTimer
## distance from core where enemy units spawn at
@export
var spawn_radius: int = 1000

## node to hold enemy units
@onready
var enemies: Node2D = $Enemies
var kill_count: int = 0

@export_category("Debugging")
@export
var no_game_over: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# delegate front end management to input manager
	$InputManager.game = self
	
	units = $PlayerUnits.get_children()
	
	EnemyUnit.core_position = core.global_position
	core.core_killed.connect(game_over)
	core.health_points = core_health
	
	# spawn first wave
	spawn_wave()
	
	wave_timer.timeout.connect(spawn_wave)
	wave_timer.start(time_between_waves)
	
	user_interface.update_unit_portraits(units)
	user_interface.update_unit_shortcut_labels(InputManager.camera.get_screen_center_position(), units)
	user_interface.restart_button.pressed.connect(start)
	

func _process(_delta):
	var reload_times = []
	for unit: PlayerUnit in units:
		reload_times.append(unit.action_one_reload_timer.time_left)
	InputManager.camera.scale_unit_shortcut_label(units)
	user_interface.core_health_label.text = "Core Health: " + str(core.health_points)
	
	time_since_start += _delta
	user_interface.game_time_label.text = str(int(time_since_start)) + " s"
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"

func enemy_killed()-> void:
	kill_count += 1
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"
	
func spawn_wave() -> void:
	for i in range(wave_unit_count):
		spawn_enemy_unit()
		
func spawn_enemy_unit() -> void:
	var newEnemy: EnemyUnit = enemy_scene.instantiate()
	var time: int = int(time_since_start)
	newEnemy.on_spawn(
		randi_range(enemy_speed_range.x + time/2, enemy_speed_range.y + time/2),
		randi_range(enemy_health_range.x + time/2, enemy_health_range.y + time/2))
	enemies.add_child(newEnemy)
	newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	newEnemy.on_death.connect(enemy_killed)

func game_over() -> void:
	if no_game_over:
		return
		
	print("***GAME OVER***")
	wave_timer.stop()
	
	# remove all remaining enemy units
	remove_child(enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
	user_interface.game_over_ui.visible = true
	

func start() -> void:
	print("***START GAME***")
	wave_timer.start(time_between_waves)
	core.health_points = core_health
	user_interface.game_over_ui.visible = false
	time_since_start = 0
	kill_count = 0
	for unit: PlayerUnit in units:
		unit.reset_health()
	
