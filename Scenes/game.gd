extends Node2D
class_name Game

@onready
var user_interface: UserInterface = $UserInterface
var portraits_set: bool = false

var enemy_scene = preload("res://Scenes/Units/enemy_unit.tscn")

var units = []

@onready
var projectiles: Node2D = $Projectiles

@onready
var shootables: Node2D = $Shootables

#region Wave settings
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
var base_enemy_health_range: Vector2i = Vector2i(50, 150)
var enemy_health_range: Vector2i = Vector2i(50, 150)
@export
var enemy_speed_range: Vector2i = Vector2i(25, 100)
## timer for resting periods between waves
@onready
var wave_timer: Timer = $WaveTimer
@onready
var linear_spawn_timer: Timer = $LinearSpawnTimer
@export
var linear_spawn_time: float = 4
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
var power_budget: float = 0
@export
var enemy_base_health: int = 100
@export
var enemy_base_speed: int = 50

## dictionary<Mutation, int level> to store mutations
var mutations = {}
static var mutation_data
var mutation_options
@onready
var spawner_component: EnemySpawnerComponent = $EnemySpawnerComponent
@onready
var mutation_timer: Timer = $MutationTimer
@export
var mutation_cooldown: float = 100
#endregion

## node to hold enemy units
@onready
var enemies: Node2D = $Enemies
var kill_count: int = 0
@onready
var blood_splatter: Node2D = $BloodSplatter

## resource system
#@export
#var resource_stock: int = 0
#@onready
#var resource_node: Node2D = $Resources

@export_category("Debugging")
@export
var no_game_over: bool = false

static var upgrade_options

## shootable objects
var dynamite_shootable = preload("res://Scenes/Shootables/dynamite.tscn")


static func _static_init():
	var is_diabled = func(data):
		return !data.disabled
		
	upgrade_options = DW_ToolBox.ImportResources("res://Data/Items/", is_diabled, true)
	mutation_data = DW_ToolBox.ImportResources("res://Data/Mutations/", is_diabled, true) 

# Called when the node enters the scene tree for the first time.
func _ready():
	# delegate front end management to input manager
	$InputManager.game = self
	
	units = $PlayerUnits.get_children()
	user_interface.core_health_bar.set_max(units[0].max_health_points)
	user_interface.core_health_bar.change_value(units[0].health_points, true)
	#InputManager._select_unit(units[0])
	bind_selected_unit_signals()
	
	# set minimap parameters
	user_interface.minimap.detection_range = spawn_radius
	
	# connect mutation timer
	mutation_timer.timeout.connect(on_mutation_timer_timeout)
	mutation_timer.start(mutation_cooldown)
	user_interface.mutation_roulette.option_selected.connect(on_mutation_selected)
	
	spawner_component.stats_changed.connect(user_interface.update_enemy_spawn_info.bind(spawner_component))
	user_interface.update_enemy_spawn_info(spawner_component)
	
	# spawn first wave
	spawner_component = $EnemySpawnerComponent
	spawner_component.on_spawn_timer_timeout()
	#spawn_wave()
	
	#wave_timer.timeout.connect(spawn_wave)
	#wave_timer.start(time_between_waves)
	#linear_spawn_timer.timeout.connect(spawner_component.spawn_enemy_unit)
	#linear_spawn_timer.start(4)
	#elite_timer.timeout.connect(spawn_elite_unit)
	#elite_timer.start(elite_spawn_time)
	
	#user_interface.update_unit_shortcut_labels(InputManager.camera.get_screen_center_position(), units)
	user_interface.restart_button.pressed.connect(start)
	
	for unit: PlayerUnit in units:
		#unit.picked_up_item.connect(user_interface.show_item_info)
		unit.experience_changed.connect(on_experience_changed)
		unit.was_selected.connect(bind_selected_unit_signals)
		unit.level_increased.connect(on_level_up)
		unit.stats_changed.connect(user_interface.update_bullet_menu)
		unit.stats_changed.connect(user_interface.update_bullet_generation_info_menu)
		unit.was_selected.connect(user_interface.update_bullet_menu)
		unit.actioned.connect(user_interface.update_bullet_menu)
		unit.bullets_changed.connect(user_interface.update_bullet_menu)
	
	# randomly place dynamite on the map
	for i in range(5):
		var new_shootable: Shootable = dynamite_shootable.instantiate()
		new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		shootables.add_child(new_shootable)
	
func _process(_delta):
	if !portraits_set:
		user_interface.update_unit_portraits(units)
		portraits_set = true
		
	var reload_times = []
	for unit: PlayerUnit in units:
		reload_times.append(unit.action_one_reload_timer.time_left)
	InputManager.camera.scale_unit_shortcut_label(units)
	InputManager.camera.scale_health_label(enemies.get_children())
	user_interface.core_health_label.text = "Health: " + str(InputManager.selected_unit.health_points)
	
	if !pause:
		time_since_start += _delta
		power_budget += _delta * time_difficulty_modifier
	time_difficulty = int(time_since_start * time_difficulty_modifier)
	
	#pulse_enemy_ratio += _delta * 0.01 * time_difficulty
	#pulse_enemy_ratio = min(pulse_enemy_ratio, 0.2)
	
	user_interface.game_time_label.text = str(int(time_since_start)) + " s"
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"
	
	user_interface.update_wave_info(
		Vector2(enemy_base_health, enemy_base_health + int(power_budget)),
		Vector2(enemy_base_speed, enemy_base_speed + int(power_budget/2))
		)
	
	# update minimap
	if InputManager.selected_unit:
		var points: PackedVector2Array = PackedVector2Array()
		var color_arr: PackedColorArray = PackedColorArray()
		# add player units
		#for unit: PlayerUnit in units:
			#points.append(unit.global_position)
			#color_arr.append(unit.temp_color)
			
		# add camera
		#points.append(CameraControl.camera.global_position)
		#color_arr.append(Color.GREEN_YELLOW)
		
		for enemy: EnemyUnit in enemies.get_children():
			points.append(enemy.global_position)
			if enemy.is_elite:
				color_arr.append(Color.PURPLE)
			else:
				color_arr.append(Color.RED)
		user_interface.minimap.update_markers(InputManager.selected_unit.global_position, points, color_arr)
		
		var bullet_points = []
		var bullet_color_arr = []
		for bullet: Projectile in projectiles.get_children():
			bullet_points.append(bullet.global_position)
			bullet_color_arr.append(Color.WHITE)
			
		user_interface.minimap.update_bullet_markers(InputManager.selected_unit.global_position, bullet_points, bullet_color_arr)
		
		var shootable_points = []
		var shootable_color_arr = []
		for shootable: Shootable in shootables.get_children():
			shootable_points.append(shootable.global_position)
			shootable_color_arr.append(Color.ORANGE)
			
		user_interface.minimap.update_shootable_markers(InputManager.selected_unit.global_position, shootable_points, shootable_color_arr)
	else:
		user_interface.minimap.update_markers(InputManager.selected_unit.global_position, [], [])
		
	user_interface.update_bullet_generation_info_menu()
	
	if !mutation_timer.is_stopped():
		user_interface.mutation_roulette.mutation_time_label.text = "Next Mutation in: " + str(int(mutation_timer.time_left) + 1) + "s"
		
	if Input.is_action_just_pressed("action_one"):
		$ClickSoundPlayer.play()
		
	CameraControl.camera.position = InputManager.selected_unit.get_local_mouse_position().normalized()
	# limit the amount of camera position offset from cursor
	CameraControl.camera.position *= min(InputManager.selected_unit.get_local_mouse_position().length()/5, 500)
			
func enemy_killed()-> void:
	kill_count += 1
	user_interface.kill_count_label.text = str(int(kill_count)) + " Kills"
	
func spawn_wave() -> void:
	for i in range(wave_unit_count + time_since_start/120):
		spawner_component.spawn_enemy_unit()
		
func add_enemy(newEnemy: EnemyUnit) -> void:
	newEnemy.game_ref = self
	enemies.add_child(newEnemy)
	if InputManager.selected_unit != null:
		newEnemy.position = InputManager.selected_unit.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	else:
		newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	newEnemy.on_death.connect(enemy_killed)
	
func spawn_elite_unit() -> void:
	var newEnemy: EnemyUnit
	newEnemy = enemy_scene.instantiate()
	
	## split power budget
	var speed_bonus: int = randi_range(0, int((power_budget * elite_unit_modifier)/2))
	var hp_bonus: int = int((power_budget * elite_unit_modifier) - speed_bonus)
	
	newEnemy.game_ref = self
	newEnemy.on_spawn(
		enemy_base_speed + speed_bonus,
		enemy_base_health + hp_bonus)
	newEnemy.increase_size(2)
	newEnemy.is_elite = true
	enemies.add_child(newEnemy)
	if InputManager.selected_unit != null:
		newEnemy.position = InputManager.selected_unit.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	else:
		newEnemy.position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * spawn_radius
	newEnemy.on_death.connect(enemy_killed)
	
func game_over() -> void:
	if no_game_over:
		return
		
	print("***GAME OVER***")
	spawner_component.spawn_timer.stop()
	wave_timer.stop()
	linear_spawn_timer.stop()
	elite_timer.stop()
	mutation_timer.stop()
	user_interface.mutation_roulette.stop_roulette()
	
	# remove all remaining enemy units
	remove_child(enemies)
	enemies.queue_free()
	enemies = Node2D.new()
	add_child(enemies)
	
	# remove all remaining projectiles
	call_deferred("remove_child", projectiles)
	projectiles.queue_free()
	projectiles = Node2D.new()
	add_child(projectiles)
	
	# remove all remaining shootables
	remove_child(shootables)
	shootables.queue_free()
	shootables = Node2D.new()
	add_child(shootables)
	
	user_interface.show_game_over_screen(false)
	pause = true

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
	
	# remove all remaining projectiles
	remove_child(projectiles)
	projectiles.queue_free()
	projectiles = Node2D.new()
	add_child(projectiles)
	
	# remove all remaining shootables
	remove_child(shootables)
	shootables.queue_free()
	shootables = Node2D.new()
	add_child(shootables)
	
	user_interface.show_game_over_screen(true)
	pause = true
	#change_resource(0)
	
func start() -> void:
	print("***START GAME***")
	
	# remove leftover resources
	#DW_ToolBox.RemoveAllChildren(resource_node)
	# remove blood splatter
	DW_ToolBox.RemoveAllChildren(blood_splatter)
	
	# spawn first wave
	spawner_component.on_spawn_timer_timeout()
	#spawn_wave()
	#wave_timer.start(time_between_waves)
	#linear_spawn_timer.start(linear_spawn_time)
	#elite_timer.start(elite_spawn_time)
	
	mutation_timer.start(mutation_cooldown)
	user_interface.mutation_roulette.mutation_time_label.visible = true

	user_interface.game_over_ui.visible = false
	time_since_start = 0
	kill_count = 0
	pause = false
	for unit: PlayerUnit in units:
		unit.reset_health()
		unit.reset_items()
		unit.reset_exp()
		unit.reset_items()
		unit.reload_action()

	# randomly place dynamite on the map
	for i in range(5):
		var new_shootable: Shootable = dynamite_shootable.instantiate()
		new_shootable.global_position = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(2000, spawn_radius)
		shootables.add_child(new_shootable)

func on_core_hit() -> void:
	user_interface.core_hit_effect.play("RESET")
	user_interface.core_hit_effect.play("core_hit_animation")
	user_interface.core_health_bar.change_value(InputManager.selected_unit.health_points)

#func change_resource(amount: int) -> void:
	#resource_stock += amount
	#resource_stock = max(resource_stock, 0)
	#print("changed resource by " + str(amount))
	#user_interface.resource_label.text = "Resource: " + str(resource_stock)

## called when selected unit is changed
## bind ui element update to selected unit signals
func bind_selected_unit_signals() -> void:
	if InputManager.selected_unit != null:
		var unit: PlayerUnit = InputManager.selected_unit
		user_interface.experience_bar.set_max(unit.required_exp_amount(unit.current_level))
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		
		if unit.is_level_up_ready():
			if unit.upgrade_options == null or unit.upgrade_options.size() == 0:
				unit.upgrade_options = get_upgrade_options()
				
			user_interface.show_upgrade_menu()
		else:
			user_interface.upgrade_menu.visible = false
			
		InputManager.selected_unit.knocked_out.connect(game_over)
		InputManager.selected_unit.was_attacked.connect(on_core_hit)
		user_interface.core_health_bar.set_max(InputManager.selected_unit.max_health_points)
		unit.health_changed.connect(on_core_hit)
			
func on_experience_changed() -> void:
	if InputManager.selected_unit != null:
		var unit: PlayerUnit = InputManager.selected_unit
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		
		if !user_interface.upgrade_menu.visible and unit.is_level_up_ready():
			unit.upgrade_options = get_upgrade_options()
			user_interface.show_upgrade_menu()

func on_level_up() -> void:
	if InputManager.selected_unit != null:
		var unit: PlayerUnit = InputManager.selected_unit
		user_interface.experience_bar.set_max(unit.required_exp_amount(unit.current_level))
		user_interface.experience_bar.change_value(unit.experience_gained, true)
		user_interface.experience_label.text = "LV " + str(unit.current_level) + "  " + str(unit.experience_gained) + "/" + str(unit.required_exp_amount(unit.current_level))
		unit.upgrade_options = get_upgrade_options()
		
func get_upgrade_options(count: int = 4):
	var output = []
	for i in range(count):
		output.append(Game.upgrade_options.pick_random())
	return output
	
func pause_time(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false

#region Mutation System
func add_mutation(item: Mutation) -> void:
	# if it exists, increase level
	if mutations.find_key(item):
		item.on_exit(spawner_component, mutations[item])
		mutations[item] += 1
		item.on_enter(spawner_component, mutations[item])
	else:
		mutations[item] = 1
		item.on_enter(spawner_component, mutations[item])
	
	# reload ui
	user_interface.update_enemy_spawn_info(spawner_component)
		
func reset_mutations() -> void:
	for item: Mutation in mutations.keys():
		item.on_exit(spawner_component, mutations[item])
	mutations.clear()
	
func get_mutation_options(count: int = 4):
	var output = []
	for i in range(count):
		output.append(Game.mutation_data.pick_random())
	return output

# show mutation selection ui
# start mutation roulette
func on_mutation_timer_timeout():
	# show mutation selection ui
	user_interface.mutation_roulette.start_roulette(Game.mutation_data)

func on_mutation_selected(option: Mutation):
	mutation_timer.stop()
	add_mutation(option)
	mutation_timer.start(mutation_cooldown)
	
#endregion
