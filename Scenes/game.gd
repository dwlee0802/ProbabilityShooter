extends Node2D
class_name Game

@onready
var user_interface: UserInterface = $UserInterface

var pulse_enemy_scene = preload("res://Scenes/Units/pulse_enemy_unit.tscn")
@export
var pulse_enemy_ratio: float = 0
var enemy_scene = preload("res://Scenes/Units/enemy_unit.tscn")

@onready var core: Core = $Core
@export var core_health: int = 1000

var units = []

@export_category("Wave Setting")
var time_since_start: float = 0
var pause: bool = false
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
@onready
var linear_spawn_timer: Timer = $LinearSpawnTimer
@export
var linear_spawn_count: int = 1
## distance from core where enemy units spawn at
@onready
var elite_timer: Timer = $EliteTimer
@export
var elite_spawn_time: float = 60
@export
var elite_unit_modifier: float = 2
@export
var spawn_radius: int = 1000
## how much stronger enemies get with time
var time_difficulty: int = 0
@export
var time_difficulty_modifier: float = 1.0

## node to hold enemy units
@onready
var enemies: Node2D = $Enemies
var kill_count: int = 0
@onready
var blood_splatter: Node2D = $BloodSplatter

## resource system
@export
var resource_stock: int = 0
@onready
var resource_node: Node2D = $Resources

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
	core.received_hit.connect(on_core_hit)
	core.health_points = core_health
	core.progressed.connect(on_core_progress)
	core.activation_complete.connect(victory)
	
	user_interface.core_health_bar.set_max(core_health)
	user_interface.core_health_bar.change_value(core_health)
	
	user_interface.core_progress_bar.set_max(100)
	user_interface.core_progress_bar.change_value(0, true)
	
	# spawn first wave
	spawn_wave()
	
	wave_timer.timeout.connect(spawn_wave)
	wave_timer.start(time_between_waves)
	linear_spawn_timer.timeout.connect(spawn_enemy_unit)
	linear_spawn_timer.start(4)
	elite_timer.timeout.connect(spawn_elite_unit)
	elite_timer.start(elite_spawn_time)
	
	user_interface.update_unit_portraits(units)
	user_interface.update_unit_shortcut_labels(InputManager.camera.get_screen_center_position(), units)
	user_interface.restart_button.pressed.connect(start)
	for unit: PlayerUnit in units:
		unit.picked_up_item.connect(user_interface.show_item_info)
	
func _process(_delta):
	var reload_times = []
	for unit: PlayerUnit in units:
		reload_times.append(unit.action_one_reload_timer.time_left)
	InputManager.camera.scale_unit_shortcut_label(units)
	InputManager.camera.scale_health_label(enemies.get_children())
	user_interface.core_health_label.text = "Core Health: " + str(core.health_points)
	
	if !pause:
		time_since_start += _delta
	time_difficulty = int(time_since_start * time_difficulty_modifier)
	
	#pulse_enemy_ratio += _delta * 0.01 * time_difficulty
	#pulse_enemy_ratio = min(pulse_enemy_ratio, 0.2)
	
	user_interface.game_time_label.text = str(int(time_since_start)) + " s"
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"
	
	user_interface.update_wave_info(
		Vector2(enemy_health_range.x, enemy_health_range.y + time_difficulty),
		Vector2(enemy_speed_range.x, enemy_speed_range.y + time_difficulty),
		pulse_enemy_ratio,
		)
		
	if Input.is_action_just_pressed("action_one"):
		$ClickSoundPlayer.play()

func enemy_killed()-> void:
	kill_count += 1
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"
	
func spawn_wave() -> void:
	for i in range(wave_unit_count):
		spawn_enemy_unit()
		
func spawn_enemy_unit() -> void:
	var newEnemy: EnemyUnit
	
	if randf() < pulse_enemy_ratio:
		newEnemy = pulse_enemy_scene.instantiate()
	else:
		newEnemy = enemy_scene.instantiate()
		
	newEnemy.game_ref = self
	newEnemy.on_spawn(
		randi_range(enemy_speed_range.x, enemy_speed_range.y + time_difficulty),
		randi_range(enemy_health_range.x, enemy_health_range.y + time_difficulty))
	enemies.add_child(newEnemy)
	newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	newEnemy.on_death.connect(enemy_killed)

func spawn_elite_unit() -> void:
	var newEnemy: EnemyUnit
	newEnemy = enemy_scene.instantiate()
	newEnemy.game_ref = self
	newEnemy.on_spawn(
		enemy_speed_range.y * elite_unit_modifier,
		enemy_health_range.y * elite_unit_modifier)
	newEnemy.increase_size(2)
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
	user_interface.show_game_over_screen(false)
	pause = true
	change_resource(0)

func victory() -> void:
	if no_game_over:
		return
		
	print("***VICTORY***")
	wave_timer.stop()
	
	# remove all remaining enemy units
	remove_child(enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
	user_interface.show_game_over_screen(true)
	pause = true
	change_resource(0)
	
func start() -> void:
	print("***START GAME***")
	
	# remove leftover resources
	DW_ToolBox.RemoveAllChildren(resource_node)
	# remove blood splatter
	DW_ToolBox.RemoveAllChildren(blood_splatter)
	
	# spawn first wave
	spawn_wave()
	wave_timer.start(time_between_waves)
	
	core.health_points = core_health
	core.activation_progress = 0
	user_interface.core_health_bar.change_value(core_health, true)
	user_interface.core_progress_bar.change_value(0, true)
	user_interface.game_over_ui.visible = false
	time_since_start = 0
	kill_count = 0
	change_resource(0)
	pause = false
	for unit: PlayerUnit in units:
		unit.reset_health()
		unit.reset_items()

func on_core_hit() -> void:
	user_interface.core_health_bar.change_value(core.health_points)
	user_interface.core_hit_effect.play("RESET")
	user_interface.core_hit_effect.play("core_hit_animation")

func on_core_progress() -> void:
	user_interface.core_progress_bar.change_value(core.activation_progress)
	user_interface.core_progress_label.text = "Progress: " + str(
		DW_ToolBox.TrimDecimalPoints(core.activation_progress / core.activation_max, 4) * 100) + "%"
	
func change_resource(amount: int) -> void:
	resource_stock += amount
	resource_stock = max(resource_stock, 0)
	print("changed resource by " + str(amount))
	user_interface.resource_label.text = "Resource: " + str(resource_stock)
	
func pause_time(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false
